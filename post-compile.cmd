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

set REBAR_BUILD_DIR=_build\emqx

rmdir /s/q %REBAR_BUILD_DIR%\conf
mkdir %REBAR_BUILD_DIR%\conf\plugins
mkdir %REBAR_BUILD_DIR%\conf\schema

pushd %REBAR_BUILD_DIR%

set ConfPath=%CD%
for /d %%i in ("lib\emqx*") do call :conf %%i

for /d %%i in ("lib\emqx*") do call :schema %%i

:conf
pushd %1
for %%f in ("etc\*.conf") do (
    :: echo %%f
    if "emqx" == "%%~nf" (
        copy %%f %ConfPath%\conf\
    ) else (
        if "acl" == "%%~nf" (
            copy %%f %ConfPath%\conf\
        ) else ( 
            if "ssl_dist" == "%%~nf" (
                copy %%f %ConfPath%\conf\
            ) else copy %%f %ConfPath%\conf\plugins
        )
    )
)
popd
:end

:schema
pushd %1
for %%f in ("priv\*.schema") do (
    ::echo %%f
    copy %%f %ConfPath%\conf\schema\
)
popd
:end
