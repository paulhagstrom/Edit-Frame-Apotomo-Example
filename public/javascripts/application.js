// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

// from http://henrik.nyh.se/2008/05/rails-authenticity-token-with-jquery
jQuery(document).ajaxSend(function(event, request, settings) {
  if (typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});