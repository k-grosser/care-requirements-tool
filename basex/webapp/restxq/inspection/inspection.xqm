(:~
 : Dieses Modul enthält die Funktionen, welche die Ansicht der Dokumentation eines XQuery-Moduls erzeugt. 
 : @author Florian Eckey, Katharina Großer
 : @version 1.1
 :)
module namespace page = 'masterthesis/modules/inspection/inspection';

import module namespace inspection ="masterthesis/modules/inspection/inspection";
import module namespace ui = 'masterthesis/modules/ui-manager';

declare namespace xd="http://www.xqdoc.org/1.0";
declare namespace i="inspections";

(:~
 : Diese Funktion bettet den HTML-Inhalt der Dokumentation der Liste aller XQuery-Module in das UI-Template ein.
 : @return Liste der Dokumentationen zu den XQuery-Modulen (XHTML) in UI-Template
 :)
declare %restxq:path("inspection/{$lng}")
        %restxq:GET
        %output:method("html")
        %output:version("5.0")
  function page:import($lng) {
    ui:page($lng,(
      <div class="col-md-8">{page:module-list($lng)}</div>,
      <div class="col-md-4"><a class="btn btn-cm bpm-btn" href="{$ui:prefix}/inspection/modules/generate" data-i18n="[title]docu.graphtitle;docu.graph"></a></div>)
)};

(:~
 : Diese Funktion generiert den HTML-Inhalt der Tabell, in der die Dokumentationen der XQuery-Module referenziert sind.
 : @return Tabelle der Dokumentationen zu den XQuery-Modulen (XHTML)
 :)
declare %restxq:path("module-list/{$lng}")
        %output:method("html")
        function page:module-list($lng) {
          let $modules := inspection:get-modules() return
          <div id="module-list">                
              <table class="table table-hover noindent">
              <thead>
                 <tr style="cursor:default">
                   <th class="vertical-middle" style="width:20%" data-i18n="docu.modul"></th>
                   <th class="vertical-middle" style="width:20%" data-i18n="docu.uri"></th>
                   <th class="vertical-middle" style="width:20%" data-i18n="docu.func"></th>
                   <th class="vertical-middle" style="width:20%" data-i18n="docu.path"></th>
                   <th class="vertical-middle" style="width:20%" data-i18n="docu.doc"></th>
                 </tr>
               </thead>
               <tbody>
               {for $module in $modules/xd:xqdoc return
                page:module-item($modules,$module,$lng)}
                 </tbody>               
               </table>
            </div>
};

(:~
 : Diese Funktion generiert den HTML-Inhalt der Tabellen-Zeile, in der die Dokumentationen der XQuery-Module referenziert sind.
 : @param $modules Alle XQuery-Module
 : @param $module Betrachtetes XQuery-Modul
 : @return Tabellen-Zeile der Dokumentationen zu einem XQuery-Modul (XHTML)
 :)
declare function page:module-item($modules,$module,$lng) {
          let $uri-hex := xs:hexBinary(hash:md5($module/xd:module/xd:uri/string()))
          let $name := $module/xd:module/xd:name/string()
          let $uri := $module/xd:module/xd:uri/string()
          let $uses := inspection:get-uses($modules,$module)
          let $function-count := count($module/xd:functions/xd:function)
          let $module-path := $module/@path/string()
          return
          <tr onclick="window.document.location='module/{$uri-hex}/{$lng}'" style="cursor:pointer; {if($uses or contains($module-path,'restxq')) then () else 'color:red'}">
            <td class="vertical-middle" style="width:20%">{$name}</td>
            
            <td class="vertical-middle" style="width:20%">{$uri}</td>
                  
            <td class="vertical-middle" style="width:20%">{$function-count}</td>
            
            <td class="vertical-middle" style="width:20%">{$module-path}</td>
            <td class="vertical-middle" style="width:20%">{if(inspection:validate-module($module)) then <i class="glyphicon glyphicon-remove-sign" style="color:red"/> else <i class="glyphicon glyphicon-ok-sign success" style="color:green"/>}</td>
            
           </tr>
};

(:~
 : Diese Funktion stößt die Generierung der Modulstruktur als Graph-ML an.
 : @return Modulstruktur als Graph-ML (download)
 :)
declare %restxq:path("inspection/modules/generate")
        %restxq:GET
        %output:method("xml")
        function page:generate-modules-graphml() {
          let $filename := "modules.graphml" 
          let $modules := inspection:get-modules()
          let $graphml := inspection:generate-graphml($modules) 
          let $file-response := <restxq:response><http:response status="200"><http:header name="Content-Disposition" value="attachment;filename={$filename}"><http:header name="Content-Type" value='text/xml'/></http:header></http:response></restxq:response> return ($file-response,$graphml)       
};