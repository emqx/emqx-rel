
cd %REBAR_BUILD_DIR%

:: Collect config files, some are direct usable
:: some are relx-overlay templated
rmdir /s/q conf
mkdir conf\plugins
@for %%Conf in ("lib\*\etc\*.conf*") do @(
     if "emqx.conf" == %%~nConf
         copy %%Conf conf\
     else ^
     if "acl.conf" == %%~nConf
         copy %%Conf conf\
     else ^
     if "ssl_dist.conf" == %%~nConf
         copy %%Conf conf\
     else ^
     copy %%Conf conf\plugins\
)

mkdir conf/schema
@for %%schema in ("lib\*\priv\*.schema") do @(
    copy %%schema conf\schema\
)
