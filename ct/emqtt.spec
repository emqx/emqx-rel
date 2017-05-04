{alias, emqttd, "../deps/emqttd/test"}.
{alias, emq_dashboard, "../deps/emq_dashboard/test"}.
{alias, emq_auth_mysql, "../deps/emq_auth_mysql/test"}.
{alias, emq_auth_pgsql, "../deps/emq_auth_pgsql/test"}.
{alias, emq_auth_mongo, "../deps/emq_auth_mongo/test"}.
{alias, emq_auth_redis, "../deps/emq_auth_redis/test"}.
{alias, emq_auth_http, "../deps/emq_auth_http/test"}.
{alias, emq_auth_clientid, "../deps/emq_auth_clientid/test"}.
{alias, emq_auth_username, "../deps/emq_auth_username/test"}.
{alias, emq_web_hook, "../deps/emq_web_hook/test"}.

{logdir, "./logs/"}.

{include, "../deps/emqttd/include"}.
{include, "../deps/emq_auth_mongo/include"}.
{include, "../deps/emq_auth_mysql/include"}.
{include, "../deps/emq_auth_redis/include"}.

{auto_compile, true}.

{suites, emqttd, all}.
{suites, emq_dashboard, all}.
{suites, emq_auth_mysql, all}.
{suites, emq_auth_pgsql, all}.
{suites, emq_auth_mongo, all}.
{suites, emq_auth_redis, all}.
{suites, emq_auth_http, all}.
{suites, emq_auth_clientid, all}.
{suites, emq_auth_username, all}.
{suites, emq_web_hook, all}.
{abort_if_missing_suites, true}.
