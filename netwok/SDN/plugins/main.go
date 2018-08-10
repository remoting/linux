package main

import (
	"fmt"

	"github.com/containernetworking/cni/pkg/skel"
	"github.com/containernetworking/cni/pkg/types"
	"github.com/containernetworking/plugins/pkg/ns"
	"github.com/remoting/docker/link"
)

const MASTER_NAME = "ens33"
const IFNAME = "yhnet"

type NetConf struct {
	types.NetConf
	Master string `json:"master"`
	Mode   string `json:"mode"`
	MTU    int    `json:"mtu"`
}

func main() {

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
	link.AddContNetwork(args, nconf)
}
