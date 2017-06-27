```
oc new-project ocp-disconnected
oc policy add-role-to-user view                -z default
oc policy add-role-to-user system:image-puller -z default
oc policy add-role-to-user system:image-pusher -z default
oc policy add-role-to-user system:image-pusher system:serviceaccount:ocp-disconnected:default -n openshift
oc policy add-role-to-user view system:serviceaccount:ocp-disconnected:default -n openshift
oadm policy add-scc-to-user privileged -z default

oc new-app https://github.com/dwojciec/ocp-disconnected-1.git  --context-dir=docker  -l name=ocp-disconnected
oc start-build ocp-disconnected-1 --follow --wait
oc create configmap conf-ansible --from-file=conf.yml
oc volume dc/ocp-disconnected --add -t 'configmap' --configmap-name=conf-ansible --mount-path=/data/ocp-disconnected/conf.yaml 

or

oc new-project ocp-disconnected
oc process -f https://raw.githubusercontent.com/dwojciec/ocp-disconnected-1/ocp-template/example/ocp-disconnected.yaml | oc create -f -
```
