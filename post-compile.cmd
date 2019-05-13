@echo off
:: cd %REBAR_BUILD_DIR%

:: echo %REBAR_BUILD_DIR%
:: Collect config files, some are direct usable
:: some are relx-overlay templated
:: pushd _build\emqx\
:: cd %REBAR_BUILD_DIR%

:: echo %REBAR_BUILD_DIR%
:: Collect config files, some are direct usable
:: some are relx-overlay templated
:: pushd _build\emqx\

:: set REBAR_BUILD_DIR=_build\emqx
pushd %REBAR_BUILD_DIR%

rmdir /s/q %REBAR_BUILD_DIR%\conf
mkdir %REBAR_BUILD_DIR%\conf\plugins
mkdir %REBAR_BUILD_DIR%\conf\schema
set ConfPath=%CD%

for /d %%i in ("lib\emqx*") do call :conf %%i

for /d %%i in ("lib\emqx*") do call :schema %%i

popd

:conf
for %%f in ("%1\etc\*.conf") do (
    :: echo %%f
    if "emqx" == "%%~nf" (
        copy %%f %REBAR_BUILD_DIR%\conf\
    ) else (
        if "acl" == "%%~nf" (
            copy %%f %REBAR_BUILD_DIR%\conf\
        ) else ( 
            if "ssl_dist" == "%%~nf" (
                copy %%f %REBAR_BUILD_DIR%\conf\
            ) else copy %%f %REBAR_BUILD_DIR%\conf\plugins
        )
    )
)
:end

:schema
for %%f in ("%1\priv\*.schema") do (
    ::echo %%f
    copy %%f %REBAR_BUILD_DIR%\conf\schema\
)
:end
