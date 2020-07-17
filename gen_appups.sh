#!/bin/sh
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

appup_text=$(cat << EOF
%% appup file
{"MajorVsn.MinorVsn.PatchVsn", % Current version
 [{<<"MajorVsn\\.MinorVsn(\\.[0-9]+)*">>, []}], % Upgrade from
 [{<<"MajorVsn\\.MinorVsn(\\.[0-9]+)*">>, []}]  % Downgrade to
}.
EOF
)

MajorV=${EMQX_DEPS_DEFAULT_VSN%%.*}
Rem=${EMQX_DEPS_DEFAULT_VSN#*.}
MinorV=${Rem%%.*}
Rem=${Rem#*.}
PatchV=$Rem
#echo ---- $MajorV $MinorV $PatchV

appup_text=$(echo "$appup_text" | sed -e "s/MajorVsn/$MajorV/g")
appup_text=$(echo "$appup_text" | sed -e "s/MinorVsn/$MinorV/g")
appup_text=$(echo "$appup_text" | sed -e "s/PatchVsn/$PatchV/g")
#echo ---- $appup_text

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

