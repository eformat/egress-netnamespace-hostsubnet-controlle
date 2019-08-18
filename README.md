# Egress Netnamespace and HostSubnets Metacontroller controller

Egress Netnamespace and HostSubnets applied based on Namespace annotations

annotation example (these go on a service object):

```
  annotations:
    network-zone-egress: 'true'
    network-zone-egress.egressIP: 192.168.130.100
```

`network-zone-egress: 'true'`- enable egress NetNamespace and Hostubnet annotations

`network-zone-egress.egressIP: 192.168.130.100` - egress ip address for namespace

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

# Test

Create a test namespace

```
oc apply -f ./test-namespace.yaml
```

make sure netnamespace egressip is created

```
oc get networkpolicy -n namespace-np-controller-test

NAME                       POD-SELECTOR   AGE
allow-from-red-dmz-infra   <none>         14s
allow-from-self            <none>         14s
allow-from-welcome         <none>         14s
```# egress-netnamespace-hostsubnet-controlle
