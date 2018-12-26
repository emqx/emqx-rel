{alias, emqx, "../deps/emqx/test"}.
{alias, emqx_dashboard, "../deps/emqx_dashboard/test"}.
{alias, emqx_auth_mysql, "../deps/emqx_auth_mysql/test"}.
{alias, emqx_auth_pgsql, "../deps/emqx_auth_pgsql/test"}.
{alias, emqx_auth_mongo, "../deps/emqx_auth_mongo/test"}.
{alias, emqx_auth_redis, "../deps/emqx_auth_redis/test"}.
{alias, emqx_auth_http, "../deps/emqx_auth_http/test"}.
{alias, emqx_auth_clientid, "../deps/emqx_auth_clientid/test"}.
{alias, emqx_auth_username, "../deps/emqx_auth_username/test"}.
{alias, emqx_web_hook, "../deps/emqx_web_hook/test"}.

{logdir, "./logs/"}.

{include, "../deps/emqx/include"}.
{include, "../deps/emqx_auth_mongo/include"}.
{include, "../deps/emqx_auth_mysql/include"}.
{include, "../deps/emqx_auth_redis/include"}.

{auto_compile, true}.

{suites, emqx, all}.
{suites, emqx_dashboard, all}.
{suites, emqx_auth_mysql, all}.
{suites, emqx_auth_pgsql, all}.
{suites, emqx_auth_mongo, all}.
{suites, emqx_auth_redis, all}.
{suites, emqx_auth_http, all}.
{suites, emqx_auth_clientid, all}.
{suites, emqx_auth_username, all}.
{suites, emqx_web_hook, all}.
{abort_if_missing_suites, true}.
