{ config, ... }: {
  config = {
    home-manager.users.${config.cfi2017.user.name} = {
      programs.k9s = {
        enable = true;
        plugins = {
          edit-secret = {
            shortCut = "Ctrl-X";
            confirm = false;
            description = "Edit decoded secret";
            scopes = [ "secrets" ];
            command = "sh";
            background = false;
            args = [
              "-c"
              ''
                tempfile=$(mktemp)
                secret=$(kubectl --context $CONTEXT get secrets --namespace $NAMESPACE $NAME -o json);
                printf '%s\n' $secret | jq '.data | map_values(@base64d)' > $tempfile;
                vim $tempfile;
                secret_data=$(cat $tempfile | jq -c '. | map_values(@base64)');
                rm $tempfile;
                printf '%s\n' $secret | jq -r --argjson secret_data "$secret_data" '.data = $secret_data' | kubectl --context $CONTEXT apply --namespace $NAMESPACE -f -;
              ''
            ];
          };
          argocd-refresh-app = {
            shortCut = "Shift-R";
            confirm = false;
            scopes = [ "apps" ];
            description = "Hard refresh";
            command = "kubectl";
            background = false;
            args = [
              "--context"
              "$CONTEXT"
              "annotate"
              "applications"
              "-n"
              "$NAMESPACE"
              "$NAME"
              "argocd.argoproj.io/refresh=hard"
            ];
          };
          argocd-sync-app = {
            shortCut = "s";
            confirm = false;
            scopes = [ "apps" ];
            description = "Sync app";
            command = "kubectl";
            background = false;
            args = [
              "--context"
              "$CONTEXT"
              "patch"
              "-n"
              "$NAMESPACE"
              "app"
              "$NAME"
              "--type"
              "merge"
              "-p"
              ''{"operation":{"sync": {"syncStrategy": {"hook": {}}}}}''
            ];
          };

          approve-csr = {
            shortCut = "a";
            confirm = false;
            description = "Approve CSR";
            scopes = [ "certificatesigningrequests" ];
            command = "kubectl";
            background = false;
            args = [
              "certificate"
              "approve"
              "$NAME"
              "--context"
              "$CONTEXT"
            ];
          };

          pvc-debug-container = {
            shortCut = "s";
            confirm = false;
            scopes = [ "pvc" ];
            description = "Shell on PVC";
            command = "sh";
            background = false;
            inputs = [
              {
                name = "podname";
                type = "string";
                label = "Pod name";
                default = "pvc-debug";
                required = true;
              }
              {
                name = "image";
                type = "dropdown";
                label = "Image";
                default = "nicolaka/netshoot:latest";
                required = true;
                options = [
                  "nicolaka/netshoot:latest"
                  "ubuntu:26.04"
                ];
              }
              {
                name = "mountpath";
                type = "string";
                label = "Mount path";
                default = "/mnt/data";
                required = true;
              }
            ];
            args = [
              "-c"
              ''

                NODE=$(
                  kubectl --context "$CONTEXT" -n "$NAMESPACE" get pods \
                      -o go-template='
                  {{- range .items }}
                    {{- $node := .spec.nodeName }}
                    {{- range .spec.volumes }}
                      {{- if .persistentVolumeClaim }}
                        {{- if eq .persistentVolumeClaim.claimName "'"$NAME"'" -}}
                  {{ $node }}
                        {{ end }}
                      {{- end }}
                    {{- end }}
                  {{- end }}' |
                    head -n1
                )
                if [ -n "$NODE" ]; then
                  NODE_LINE="nodeName: $NODE"
                else
                  NODE_LINE=""
                fi

                echo "Starting a shell pod with PVC - $NAME mounted at $INPUT_MOUNTPATH"

                {
                cat <<EOF
                apiVersion: v1
                kind: Pod
                metadata:
                  name: $INPUT_PODNAME
                  namespace: $NAMESPACE
                spec:
                  $NODE_LINE
                  restartPolicy: Never
                  tolerations:
                    - operator: Exists
                  containers:
                    - name: shell
                      image: $INPUT_IMAGE
                      command: ["sh"]
                      stdin: true
                      tty: true
                      volumeMounts:
                        - name: vol
                          mountPath: $INPUT_MOUNTPATH
                  volumes:
                    - name: vol
                      persistentVolumeClaim:
                        claimName: $NAME
                EOF
                } | kubectl --context $CONTEXT apply -f - >/dev/null 2>&1

                echo "Waiting for pod to be ready."
                if ! kubectl --context $CONTEXT -n $NAMESPACE wait --for=condition=Ready pod/$INPUT_PODNAME --timeout=60s; then
                  echo "Pod did not become Ready. Likely a ReadWriteOnce conflict."
                  echo "Press Enter to return to k9s."
                  read dummy
                  kubectl --context $CONTEXT -n $NAMESPACE delete pod $INPUT_PODNAME --ignore-not-found --grace-period=0 --force >/dev/null 2>&1
                  exit 0
                fi

                kubectl --context $CONTEXT -n $NAMESPACE exec -it $INPUT_PODNAME -- bash || echo "Could not exec into pod."

                echo "Cleaning up pod."
                kubectl --context $CONTEXT -n $NAMESPACE delete pod $INPUT_PODNAME --ignore-not-found --grace-period=0 --force >/dev/null 2>&1
              ''
            ];
          };
        };
      };
    };
  };
}
