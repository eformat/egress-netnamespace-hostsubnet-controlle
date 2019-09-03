function(request) {
  local namespace = request.object,
  local egressIP = namespace.metadata.annotations["network-zone-egress.egressIP"],
  local egressCIDR = namespace.metadata.annotations["network-zone-egress.egressCIDR"],
  local egressHosts = std.split(namespace.metadata.annotations["network-zone-egress.egressHosts"],","),

  // Create a NetNamespace for each namespace
  attachments: [
    {
      apiVersion: "network.openshift.io/v1",
      kind: "HostSubnet",
      egressCIDRs: [ egressCIDR ],
      host: eh,
      metadata: {
        name: eh
      }
    }
  for eh in egressHosts
  ] + [
    {
      apiVersion: "network.openshift.io/v1",
      kind: "NetNamespace",
      egressIPs: [ egressIP ],
      netname: namespace.metadata.name,      
      metadata: {
        name: namespace.metadata.name
      }
    }
  ]
}
