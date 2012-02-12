// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require rails
//= require plugins
//= require jquery.dataTables.min
//= require jquery.dataTables.languages
//= require jquery.jeditable.mini
//= require chosen.jquery.min
//= require excanvas.min
//= require jquery.flot.min
//= require jquery.flot.pie.min
//= require jquery.tools.custom
//= require i18n
//= require i18n/translations
//= require dashboard
//= require apps
//= require appsshow
//= require services
//= require sessions
//= require system
//= require users
//= require_self

// JQuery handler to close flash messages
$(function() {
  $('body').on('click', '#flash .close', function(e) {
    $(this).parent('#flash').fadeOut('slow');
    e && e.preventDefault()
  });
});

// Browser Update
var $buoop = {vs:{i:8,f:4,o:11,s:5,n:9}}
$buoop.ol = window.onload;
window.onload=function(){
  try {if ($buoop.ol) $buoop.ol();}catch (e) {}
  var e = document.createElement("script");
  e.setAttribute("type", "text/javascript");
  e.setAttribute("src", "http://browser-update.org/update.js");
  document.body.appendChild(e);
}

// Google Analytics
var _gaq=[['_setAccount','UA-XXXXX-X'],['_trackPageview'],['_trackPageLoadTime']];
(function(d,t){var g=d.createElement(t),s=d.getElementsByTagName(t)[0];
g.src=('https:'==location.protocol?'//ssl':'//www')+'.google-analytics.com/ga.js';
s.parentNode.insertBefore(g,s)}(document,'script'));