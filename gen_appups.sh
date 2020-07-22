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

if [ -z ${PROFILE} ]; then
    echo "error: Enviornment Variable 'PROFILE' is not set"
    exit 1
fi

appup_text=$(cat << EOF
%% appup file
{"MajorVsn.MinorVsnPatchOrExtVsn", % Current version
 [{<<"MajorVsn\\.MinorVsn(\\.[0-9]+)*">>, []}], % Upgrade from
 [{<<"MajorVsn\\.MinorVsn(\\.[0-9]+)*">>, []}]  % Downgrade to
}.
EOF
)

if echo "${EMQX_DEPS_DEFAULT_VSN}" | grep -q '-'; then
    Vsn=${EMQX_DEPS_DEFAULT_VSN%%-*}
    PatchOrExtV="-${EMQX_DEPS_DEFAULT_VSN#*-}"
    MajorV=${Vsn%%.*}
    Rem=${Vsn#*.}
    if echo "${Rem}" | grep -q '\.'; then
        MinorV=${Rem%%.*}
        Rem=${Rem#*.}
        PatchOrExtV=".${Rem}""${PatchOrExtV}"
    else
        MinorV=${Rem}
    fi
else
    MajorV=${EMQX_DEPS_DEFAULT_VSN%%.*}
    Rem=${EMQX_DEPS_DEFAULT_VSN#*.}
    #echo ++${Rem}
    if echo "${Rem}" | grep -q '\.'; then
        MinorV=${Rem%%.*}
        Rem=${Rem#*.}
        PatchOrExtV=".$Rem"
    else
        MinorV=$Rem
        PatchOrExtV=""
    fi
fi;

#echo ---- $MajorV $MinorV $PatchOrExtV

appup_text=$(echo "$appup_text" | sed -e "s/MajorVsn/$MajorV/g")
appup_text=$(echo "$appup_text" | sed -e "s/MinorVsn/$MinorV/g")
appup_text=$(echo "$appup_text" | sed -e "s/PatchOrExtVsn/$PatchOrExtV/g")
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

for tarf in _build/${PROFILE}/rel/emqx/*.tar.gz _build/${PROFILE}/rel/emqx/*.zip; do
    if echo "${tarf}" | grep -q ${EMQX_DEPS_DEFAULT_VSN};
    then echo >> /dev/null;
    else
        tard="/tmp/emqx_untar_$(date +%s)";
        echo "===> unzip ${tarf}";
        rm -rf ${tard};
        if echo "${tarf}" | grep -q '.zip';
        then
            mkdir -p "${tard}";
            unzip -q ${tarf} -d ${tard};
        else
            mkdir -p "${tard}/emqx";
            tar zxf ${tarf} -C "${tard}/emqx";
        fi;
        for d in ${tard}/emqx/lib/*; do
            relf="_build/${PROFILE}/rel/emqx/lib/$(basename ${d})";
            if ! [ -d ${relf} ]; then
                cp -nr "$d" "${relf}";
            fi;
        done;
        for d in ${tard}/emqx/releases/*; do
            if [ -d ${d} ]; then
                cp -nr "$d" "_build/${PROFILE}/rel/emqx/releases/";
            fi;
        done;
        echo >> /dev/null;
    fi;
done;
