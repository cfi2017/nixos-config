{ config, ... }:
{
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
        };
      };
    };
  };
}
