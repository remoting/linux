package link

import (
	"fmt"
	"net"
	"os"

	"github.com/containernetworking/cni/pkg/skel"
	"github.com/containernetworking/cni/pkg/types"
	"github.com/containernetworking/plugins/pkg/ip"
	"github.com/containernetworking/plugins/pkg/ns"
	"github.com/vishvananda/netlink"
)

func AddContNetwork(args *skel.CmdArgs, conf types.NetConf) {
	// Select the first 11 characters of the containerID for the host veth.
	hostVethName := "cali" + args.ContainerID
	contVethName := args.IfName

	fmt.Printf("Setting the host side veth name to %s\n", hostVethName)

	// Clean up if hostVeth exists.
	if oldHostVeth, err := netlink.LinkByName(hostVethName); err == nil {
		if err = netlink.LinkDel(oldHostVeth); err != nil {
			fmt.Printf("failed to delete old hostVeth %v: %v\n", hostVethName, err)
		}
		fmt.Printf("Cleaning old hostVeth: %v\n", hostVethName)
	}
	err := ns.WithNetNSPath(args.Netns, func(hostNS ns.NetNS) error {
		veth := &netlink.Veth{
			LinkAttrs: netlink.LinkAttrs{
				Name:  contVethName,
				Flags: net.FlagUp,
				MTU:   1500,
			},
			PeerName: hostVethName,
		}

		if err := netlink.LinkAdd(veth); err != nil {
			fmt.Errorf("Error adding veth %+v: %s", veth, err)
			return err
		}

		hostVeth, err := netlink.LinkByName(hostVethName)
		if err != nil {
			err = fmt.Errorf("failed to lookup %q: %v", hostVethName, err)
			return err
		}
		// Explicitly set the veth to UP state, because netlink doesn't always do that on all the platforms with net.FlagUp.
		// veth won't get a link local address unless it's set to UP state.
		if err = netlink.LinkSetUp(hostVeth); err != nil {
			return fmt.Errorf("failed to set %q up: %v", hostVethName, err)
		}

		contVeth, err := netlink.LinkByName(contVethName)
		if err != nil {
			err = fmt.Errorf("failed to lookup %q: %v", contVethName, err)
			return err
		}

		// Fetch the MAC from the container Veth. This is needed by Calico.
		contVethMAC := contVeth.Attrs().HardwareAddr.String()
		fmt.Printf("Found MAC for container veth %s \n", contVethMAC)

		// Now that the everything has been successfully set up in the container, move the "host" end of the
		// veth into the host namespace.
		if err = netlink.LinkSetNsFd(hostVeth, int(hostNS.Fd())); err != nil {
			return fmt.Errorf("failed to move veth to host netns: %v", err)
		}

		return nil
	})

	if err != nil {
		fmt.Errorf("Error creating veth: %s", err)
	}
}

// CleanUpNamespace deletes the devices in the network namespace.
func CleanUpNamespace(args *skel.CmdArgs) error {
	// Only try to delete the device if a namespace was passed in.
	if args.Netns != "" {
		fmt.Printf("Checking namespace & device exist.")
		devErr := ns.WithNetNSPath(args.Netns, func(_ ns.NetNS) error {
			_, err := netlink.LinkByName(args.IfName)
			return err
		})

		if devErr == nil {
			fmt.Fprintf(os.Stderr, "Calico CNI deleting device in netns %s\n", args.Netns)
			err := ns.WithNetNSPath(args.Netns, func(_ ns.NetNS) error {
				_, err := ip.DelLinkByNameAddr(args.IfName)
				return err
			})

			if err != nil {
				return err
			}
		} else {
			fmt.Printf("veth does not exist, no need to clean up.")
		}
	}

	return nil
}
