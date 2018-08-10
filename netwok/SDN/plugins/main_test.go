package main

import (
	"fmt"
	"testing"

	"github.com/containernetworking/cni/pkg/skel"
	"github.com/containernetworking/cni/pkg/types"
	"github.com/containernetworking/plugins/pkg/ns"
	"github.com/remoting/docker/link"
)

func TestConsul002(t *testing.T) {
	nconf := types.NetConf{
		CNIVersion: "0.3.1",
		Name:       "testConfig",
		Type:       "yhnet",
	}
	argconf := fmt.Sprintf(`{
    "cniVersion": "0.3.1",
    "name": "mynet",
    "type": "macvlan",
    "master": "%s",
    "ipam": {
        "type": "host-local",
        "subnet": "10.1.2.0/24"
    }
}`, MASTER_NAME)

	targetNs, _ := ns.NewNS()
	args := &skel.CmdArgs{
		ContainerID: "dummy",
		Netns:       targetNs.Path(),
		IfName:      IFNAME,
		StdinData:   []byte(argconf),
	}
	fmt.Printf("%v", nconf)
	link.CleanUpNamespace(args)
	//link.AddContNetwork(args, nconf)
}
