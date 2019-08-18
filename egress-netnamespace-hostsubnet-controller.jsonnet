function(request) {
  local namespace = request.object,
  local egressIP = namespace.metadata.annotations["network-zone-egress.egressIP"],

  // Create a NetNamespace for each namespace
  attachments: [
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
