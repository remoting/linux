package main

import (
	"fmt"
	"net"

	"github.com/remoting/docker/link"
)

func main() {
	ifaces, _ := net.Interfaces()
	fmt.Printf("Interfaces: %v\n", ifaces)
	fmt.Println("Web Server")
	//link.Add()
	//link.CreateHostVeth("sss")
	//link.CreateVeth("aa", "bb")
	link.Aaa()
}
