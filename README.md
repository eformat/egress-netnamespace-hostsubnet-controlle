# Egress Netnamespace and HostSubnets Metacontroller controller

Egress Netnamespace and HostSubnets applied based on Namespace annotations

annotation example (these go on a service object):

```
  annotations:
    network-zone-egress: 'true'
    network-zone-egress.egressIP: 192.168.130.100
    network-zone-egress.egressHosts: i1,i2
```

`network-zone-egress: 'true'`- enable egress NetNamespace and Hostubnet annotations

`network-zone-egress.egressIP: 192.168.130.100` - egress ip address for namespace

`network-zone-egress.egressHosts: i1,i2` - router(s) to host namesapce ip's (more than one for HA)

This controller uses the metacontroller framework.

# Deploy the metacontroller

```
oc adm new-project metacontroller
oc apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/metacontroller/master/manifests/metacontroller-rbac.yaml
oc apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/metacontroller/master/manifests/metacontroller.yaml
```

Use local versions in this repo

```
oc adm new-project metacontroller
oc apply -f ./metacontroller-rbac.yaml
oc apply -f ./metacontroller.yaml
```

# Deploy the egress netnamespace hostsubnet controller
```
oc project metacontroller
oc create configmap egress-netnamespace-hostsubnet-controller --from-file=egress-netnamespace-hostsubnet-controller.jsonnet --dry-run -o yaml | oc apply --force -f-
oc apply -f egress-netnamespace-hostsubnet-controller.yaml
```

## Hack - we need to fool the metacontroller into believing it created the resource, else we get an 'already created' error (the netnamesapce controller owns this resource intially)
```
oc apply -f test-namespace.yaml
# netnamespace
oc annotate --overwrite netnamespace test-ns metacontroller.k8s.io/decorator-controller=egress-netnamespace-hostsubnet-controller
nsuid=$(oc get namespace test-ns -o jsonpath="{.metadata.uid}")
oc patch netnamespace test-ns -p '{"metadata":{"ownerReferences":[{"apiVersion":"v1","blockOwnerDeletion":true,"controller":true,"kind":"Namespace","name":"test-ns","uid": "'$nsuid'"}]}}'
# hostsubnet
oc annotate --overwrite hostsubnet i{1..2} metacontroller.k8s.io/decorator-controller=egress-netnamespace-hostsubnet-controller
nsuid=$(oc get namespace test-ns -o jsonpath="{.metadata.uid}")
oc patch hostsubnet i{1..2} -p '{"metadata":{"ownerReferences":[{"apiVersion":"v1","blockOwnerDeletion":true,"controller":true,"kind":"Namespace","name":"test-ns","uid": "'$nsuid'"}]}}'
```

# Test
Create a test namespace

```
oc apply -f ./test-namespace.yaml
```

make sure netnamespace egress ip is created
```
oc get netnamespace

NAME                                NETID      EGRESS IPS
test-ns                             6154464    [192.168.130.100]
```

make sure the hostsubnet is allocted and serving from one of the routers
```
oc get hostsubnet

NAME   HOST   HOST IP          SUBNET          EGRESS CIDRS           EGRESS IPS
i1     i1     192.168.130.14   10.128.2.0/23   [192.168.130.100/32]   [192.168.130.100]
i2     i2     192.168.130.15   10.131.0.0/23   [192.168.130.100/32]   []
```

# Tidy up
Delete the namespace (we also need to bounce the egress netnamespace controller pod, else we will cache the ownership - and get 0 netid is we recreate the namesapces - not ideal)
```
oc delete -f test-namespace.yaml
oc delete pod -l app=egress-netnamespace-hostsubnet-controller -n metacontroller
```
