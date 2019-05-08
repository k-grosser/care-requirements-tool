(:~
 : Dieses Modul stellt Templates für die HTML Seiten bereit.
 : @version 1.2
 : @author Florian Eckey, Katharina Großer
 :)
module namespace ui = 'masterthesis/modules/ui-manager';

import module namespace util="masterthesis/modules/utilities";

declare variable $ui:prefix := "";

(:~
 : Diese Funktion generiert das Template für die HTML Seite. Es generiert die Imports für alle verwendeten Frameworks (Bootstrap, JQuery) um den übergebenen Inhalt
 : @param $content Der HTML Inhalt, welcher in die HTML Seite eingebettet werden soll
 : @return HTML Seite (komplett)
:)
declare function ui:page($lng, $content) {
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <meta charset="utf-8"/>
      <title>CARE</title>
      <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  
      <!-- Loading Bootstrap -->
      <link href="{$ui:prefix}/static/bootstrap-3.3.4-dist/css/bootstrap.min.css" rel="stylesheet"/>
  
      <!-- Loading Flat UI -->
      <link href="{$ui:prefix}/static/flat-ui/css/flat-ui.min.css" rel="stylesheet"/>
      
      <!-- Loading Flat UI customizations-->
      <link href="{$ui:prefix}/static/care/css/flat-ui-custom.css" rel="stylesheet"/>
      
      <!-- Loading Immybox Framework CSS -->
      <link rel='stylesheet' type='text/css' href='{$ui:prefix}/static/immybox-master/immybox.css'/>
      
      <!-- Loading CARE UI -->
      <link href="{$ui:prefix}/static/care/css/care-ui.css" rel="stylesheet"/>
      <link href="{$ui:prefix}/static/care/css/requirements.css" rel="stylesheet"/>
  
      <!-- link rel="shortcut icon" href="img/favicon.ico"/-->
  
      <!-- jQuery (necessary for Flat UIs and other JavaScript plugins) -->
      <script src="{$ui:prefix}/static/flat-ui/js/vendor/jquery.min.js"></script>
      
      <!-- Include all compiled plugins (below), or include individual files as needed -->
      <script src="{$ui:prefix}/static/flat-ui/js/vendor/video.js"></script>
      <script src="{$ui:prefix}/static/flat-ui/js/flat-ui.min.js"></script>
      
      <!-- Loading AJAX Framework -->
      <script src="{$ui:prefix}/static/care/js/ajax.js"></script>
      
      <!-- Loading Immybox Framework JS -->
      <script src='{$ui:prefix}/static/immybox-master/jquery.immybox.js'></script>
      
      <!-- Loading Bootstrap JS -->
      <script src="{$ui:prefix}/static/bootstrap-3.3.4-dist/js/bootstrap.min.js"></script>
      
      <!-- Loading jQuery i18next Framework for localization -->
      <script src="{$ui:prefix}/static/jquery-i18next/i18next.min.js"></script>
      <script src="{$ui:prefix}/static/jquery-i18next/jquery-i18next.min.js"></script>
      
      <!-- Loading moment.js Framework for date-time handling with localization -->
      <script src="{$ui:prefix}/static/momentjs/moment-with-locales.min.js"></script>
      
      <!-- Loading CARE CUSTOM JS -->
      <script src="{$ui:prefix}/static/care/js/requirements.js"></script>
      <script src="{$ui:prefix}/static/care/js/inspections.js"></script>
      
      
      <!-- Loading BPMN.IO -->
      <script src="{$ui:prefix}/static/bpmn-js-seed-master/bower_components/bpmn-js/dist/bpmn-viewer.js"></script>
      
      <!-- HTML5 shim, for IE6-8 support of HTML5 elements. All other JS at the end of file. -->
      <!--[if lt IE 9]>
        <script src="{$ui:prefix}/static/flat-ui/js/vendor/html5shiv.js"></script>
        <script src="{$ui:prefix}/static/flat-ui/js/vendor/respond.min.js"></script>
      <![endif]-->
    </head>
    <body onload="{if($lng = 'en') then 'setLngEN()' else ''}">
          
      {ui:navbar($lng)}
      <div id="main-content">{$content}</div>

    <script src="{$ui:prefix}/static/care/js/localization.js"></script>
    </body>
  </html>
};

(:~
 : Generated the menue bar
 : @return menue bar (XHTML)
 :)
declare function ui:navbar($lng) {

  <div class="row demo-row">
        <div class="col-xs-12">
          <nav class="navbar navbar-inverse navbar-embossed navbar-fixed-top" role="navigation">
            <div class="navbar-header">
              <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse-01">
                <span class="sr-only">Toggle navigation</span>
              </button>
              <a class="navbar-brand brand" href="{$ui:prefix}/care/{$lng}" data-i18n="brand"></a>
            </div>
            <div class="collapse navbar-collapse" id="navbar-collapse-01">
            
              <ul class="nav navbar-nav navbar-left">
                <li><a id="processnav" href="{$ui:prefix}/requirements-manager/{$lng}" data-i18n="[html]navi.processmanager"></a></li>
                <li class="pull-right"><a href="{$ui:prefix}/requirements-manager/list/{$lng}"  data-i18n="[html]navi.reqlist"></a></li>
                <li class="pull-right"><a href="{$ui:prefix}/glossary/{$lng}" data-i18n="[html]navi.glossary"></a></li>
               </ul>
               
               <ul class="pull-right">
                 <li class="pull-right lng-btn"><a id="lang-en" class="care-link lng-btn" onclick="window.location = $(location).attr('href').replace('/de', '/en');">EN</a></li>
                 <li class="pull-right lng-btn"><a id="lang-de" class="activeLng lng-btn" onclick="window.location = $(location).attr('href').replace('/en', '/de');">DE</a></li>
               </ul>
               
            </div>
          </nav>
        </div>
      </div>
};

(:~
 : Generates XHTML code for info tooltips based on bootstrap tooltips
 : @param $descriptionkey i18next key of the description text that is shown in the tooltip
 : @return tooltip XHTML
 :)
declare function ui:info-tooltip($descriptionkey) {
  <i data-toggle="tooltip" data-placement="left" data-template="{util:serialize-html(<div class='tooltip' role='tooltip'><div class='tooltip-arrow'/><div class='info-tooltip tooltip-inner'/></div>)}" data-i18n="[title]{$descriptionkey}" class="glyphicon glyphicon-question-sign pull-right" style="font-size:17pt"/>
};

(:~
 : Diese Funktion generiert den HTML Code für ein Autocomplete Input Feld
 : @param $list Liste von Elementen, welche in der Autocomplete Liste vorgeschlagen werden
 : @param $input Das Input-Element (HTML), welches zu einem Autocomplete-Feld werden soll
 : @return HTML und JavaScript, welches das Autocomplete Feld erzeugen
 :)
declare function ui:autocomplete-search-bar($list,$input) {
    let $rId := $input/@id/string() return (
        <script type='text/javascript'>
        <![CDATA[
          $(function() {
            $(]]>{"'#"||$rId||"'"}<![CDATA[).immybox({
              choices: [
        ]]>
        {for $item in $list return ("&#123;text: '" || $item/@Name/string() || "', value: '" || $item/@Id/string() || "', type: '"||$item/@Type/string()||"', icon: '"||$item/@Icon/string()||"'&#125;,")}
        <![CDATA[
              ]
            });
          });
        ]]></script>
        ,$input)
};