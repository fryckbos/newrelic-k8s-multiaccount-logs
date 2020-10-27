#!/bin/bash

OUTPUT_CONFIG=/output-newrelic.conf

function generate-config {
    if [ -e $OUTPUT_CONFIG.new ]; then rm $OUTPUT_CONFIG.new; fi

    NAMESPACES=$(kubectl get secret --all-namespaces --field-selector metadata.name=$SECRET -o=jsonpath="{.items.*.metadata.namespace}")
    for NAMESPACE in $NAMESPACES; do
        LICENSE=$(kubectl get secret $SECRET -n $NAMESPACE -o=jsonpath="{.data.$SECRET_KEY}" | base64 -d)
cat >> $OUTPUT_CONFIG.new << EOF
[OUTPUT]
    Name  newrelic
    Match kube.${NAMESPACE}.*
    licenseKey ${LICENSE}
    endpoint ${ENDPOINT}

EOF
    done
}

generate-config
mv $OUTPUT_CONFIG.new $OUTPUT_CONFIG

echo "Applying configuration to match:"
cat $OUTPUT_CONFIG | grep Match

( while [ 1 ]; do
    /opt/td-agent-bit/bin/td-agent-bit -c /fluent-bit/etc/fluent-bit.conf -e /out_newrelic.so
    sleep 5
done ) &

while [ 1 ]; do
    generate-config
    
    if ! diff $OUTPUT_CONFIG.new $OUTPUT_CONFIG > /dev/null ; then
        echo "Configuration changed. Applying configuration to match:"
        cat $OUTPUT_CONFIG.new | grep Match
        echo

        mv $OUTPUT_CONFIG.new $OUTPUT_CONFIG
        pkill td-agent-bit
    fi

    sleep 60
done
