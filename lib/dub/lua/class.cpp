/**
 *
 * MACHINE GENERATED FILE. DO NOT EDIT.
 *
 * Bindings for class {{self.name}}
 *
 * This file has been generated by dub {{dub.version}}.
 */
{% for h in self:headers() do %}
#include "{{h.path}}"
{% end %}

{% for method in self:methods() do %}
/** {{method:fullname()}}
 * {{method:source()}}
 */
static int {{self.name}}_{{method.name}}(lua_State *L) {
  try {
    {| binder:functionBody(self, method) |}
  } catch (std::exception &e) {
    lua_pushfstring(L, "{{method.name}}: %s", e.what());
  } catch (...) {
    lua_pushfstring(L, "{{method.name}}: Unknown exception");
  }
  return lua_error(L);
}

{% end %}
