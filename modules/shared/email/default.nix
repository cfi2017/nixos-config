{
  config,
  options,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  user = config.cfi2017.user.name;
in
{
  config = lib.mkMerge [
    (lib.mkIf config.cfi2017.isLinux {
      cfi2017.core.zfs = lib.mkMerge [
        (lib.mkIf config.cfi2017.persistence.enable {
          homeDataLinks = [
            {
              directory = ".local/share/email";
              mode = "0700";
            }
          ];
          homeCacheLinks = [
          ];
          # homeCacheFileLinks = [".claude.json"];
        })
      ];
    })
    {
      home-manager = {
        users = {
          "${user}" =
            { ... }:
            {
              accounts.email.maildirBasePath = ".local/share/email";
              programs = {
                msmtp.enable = true;
                lieer.enable = true;
                neomutt = {
                  enable = true;
                  editor = "${pkgs.neovim}/bin/nvim";
                  extraConfig = ''
                    set arrow_cursor
                    set record = ""
                    set spool_file = "Inbox"
                    set sidebar_visible
                    set sidebar_width = 30
                    set sidebar_short_path = yes
                    set sidebar_component_depth = 1
                    set sidebar_delim_chars = "/"
                    set sidebar_folder_indent = yes
                    set sidebar_indent_string = ' '
                    # set sidebar_format = '%B?F? [%F]?%* %?N?%N/?%S'
                    bind index,pager K sidebar-prev
                    bind index,pager J sidebar-next
                    bind index,pager O sidebar-open
                    set autoedit
                    set noconfirmappend
                    set copy=no
                    set delete=yes
                    set edit_headers
                    set date_format="%m/%d %R"
                    set index_format="%4C %Z %D %-15.15F (%4c) %s"
                    set help
                    set include
                    set nomark_old
                    set mail_check=130
                    set mail_check_recent=yes
                    set new_mail_command="notify-send 'New mail!'"
                    set mail_check_stats = yes
                    set mail_check_stats_interval = 130
                    set pager_index_lines=6
                    set reply_to
                    set reverse_name
                    ignore *
                    unignore from: subject to cc mail-followup-to \
                      date x-mailer x-url

                    color hdrdefault white default
                    color quoted white default
                    color signature cyan default
                    color indicator cyan default
                    color error red default
                    color status white default
                    color tree cyan default
                    color tilde cyan default
                    color message cyan default
                    color markers cyan default
                    color attachment magenta default
                    color search default green
                    color header yellow default ^(From|Subject):
                    color body cyan default "(ftp|http|https)://[^ ]+"
                    color body cyan default [-a-z_0-9.\+]+@[-a-z_0-9.]+
                    color underline green default

                    mono quoted bold

                    auto_view application/x-gunzip
                    auto_view application/x-gzip


                    # local rc?
                    set query_command = "lbdbq '%s'"
                    bind editor <Tab> complete-query
                    auto_view text/x-vcard text/html text/enriched
                    alternative_order text/plain text/enriched text/html
                    set sort="threads"
                    set strict_threads="yes"
                    set sort_browser="reverse-date"
                    set sort_aux="last-date-received"
                    unset collapse_unread
                    bind index - collapse-thread
                    bind index _ collapse-all
                  '';
                };
                notmuch = {
                  enable = true;
                  hooks = {
                    # preNew = "mbsync --all";
                  };
                };
              };
            };
        };
      };
    }
  ];
}
