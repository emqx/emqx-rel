#!/bin/bash
## generate default .appup files for each emqx* application
##

write_file() {
    filename=$1
    text=$2
    #echo "writing to file: $filename"
    echo "$text" > "$filename"
}

if [ -z ${EMQX_DEPS_DEFAULT_VSN} ]; then
    echo "error: Enviornment Variable 'EMQX_DEPS_DEFAULT_VSN' is not set"
    exit 1
fi

read -d '' appup_text << EOF
%% appup file
{"MajorVsn.MinorVsn.PatchVsn", % Current version
 [{<<"MajorVsn\\.MinorVsn(\\.[0-9]+)*">>, []}], % Upgrade from
 [{<<"MajorVsn\\.MinorVsn(\\.[0-9]+)*">>, []}]  % Downgrade to
}.
EOF

IFS0=IFS; IFS='.';
read -ra Vsns <<< "$EMQX_DEPS_DEFAULT_VSN";
IFS=IFS0;

appup_text=${appup_text//MajorVsn/${Vsns[0]}}
appup_text=${appup_text//MinorVsn/${Vsns[1]}}
appup_text=${appup_text//PatchVsn/${Vsns[2]}}

for appdir in _checkouts/emqx* ; do
    mkdir -p "${appdir}/ebin"
    appname=${appdir#_checkouts/}
    filename="${appname}.appup"
    filepath="${appdir}/ebin/${filename}"
    if [ -f "$filepath" ]; then
        if ! grep -q "${EMQX_DEPS_DEFAULT_VSN}" $filepath; then
            write_file "$filepath" "$appup_text"
        fi
    else
        write_file "$filepath" "$appup_text"
    fi
done

