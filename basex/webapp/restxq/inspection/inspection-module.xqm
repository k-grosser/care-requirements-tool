(:~
 : Dieses Modul enthält die Funktionen, welche die Ansicht der Dokumentation eines XQuery-Moduls erzeugt. 
 : @author Florian Eckey, Katharina Großer
 : @version 1.1
 :)
module namespace page = 'masterthesis/modules/inspection/inspection-module';

import module namespace ui = 'masterthesis/modules/ui-manager';
import module namespace inspection ="masterthesis/modules/inspection/inspection";
import module namespace utilities="masterthesis/modules/utilities";
import module namespace functx="http://www.functx.com";

declare namespace xd="http://www.xqdoc.org/1.0";
declare namespace i="inspections";

(:~
 : Diese Funktion bettet den HTML-Inhalt der Dokumentation eines XQuery-Modul in das UI-Template ein.
 : @param $uri-hex Hexadezimal des URI's (namespaces) des Moduls
 : @return Dokumentation des XQuery-Moduls (XHTML) in UI-Template
 :)
declare %restxq:path("inspection/module/{$uri-hex}/{$lng}")
        %restxq:GET
        %output:method("html")
        %output:version("5.0")
  function page:module($uri-hex,$lng) {
     ui:page($lng, page:content($uri-hex, $lng))
};

(:~
 : Diese Funktion erzeugt den HTML-Inhalt der Dokumentation eines XQuery-Moduls.
 : @param $uri-hex Hexadezimal des URI's (namespaces) des Moduls
 : @return Dokumentation des XQuery-Moduls (XHTML)
 :)
declare %restxq:path("inspection/module/content/{$uri-hex}/{$lng}")
        function page:content($uri-hex,$lng) {
          let $modules := inspection:get-modules()
          let $module := $modules/xd:xqdoc[xs:hexBinary(hash:md5(./xd:module/xd:uri/string()))=$uri-hex]
          let $imports := $module/xd:imports/xd:import
          let $uses := inspection:get-uses($modules,$module)
          let $namespaces := $module/xd:namespaces/xd:namespace
          let $variables := $module/xd:variables/xd:variable
          let $functions := $module/xd:functions/xd:function
          let $author := $module/xd:module/xd:comment/xd:author/string()
          let $version := $module/xd:module/xd:comment/xd:version/string()
          let $description := $module/xd:module/xd:comment/xd:description/string()
          return
          if($module) then <div id="module-content" class="col-md-12">
          <h4>Modul&#160;{$module/xd:module/xd:uri/string()}</h4>
          
          <ul class="list-unstyled float col-md-7 {if($description) then 'success' else 'danger'}">
            <h5 data-i18n="docu.desc"></h5>
            {if($description) then $description else <div style="color:red" data-i18n="docu.nodesc"></div>}
          </ul>
          <ul class="list-unstyled float col-md-1">
            <h5 data-i18n="docu.version"></h5>
            {if($version) then $version else <div style="color:red" data-i18n="docu.noversion"></div>}
          </ul>
          <ul class="list-unstyled float col-md-2">
            <h5 data-i18n="docu.author"></h5>
            {if($author) then $author else <div style="color:red" data-i18n="docu.noauthor"></div>}
          </ul>
          <ul class="list-unstyled float col-md-5">
            <h5 data-i18n="docu.imports"></h5>
            {if($imports) then $imports ! 
            <li>
              <a href="{$ui:prefix}/inspection/module/{xs:hexBinary(hash:md5(./xd:uri/string()))}/{$lng}"><span class="glyphicon glyphicon-import"></span>&#160;{./xd:uri/string()}</a>
            </li>
            else 
            <li data-i18n="docu.noimports"></li>}
          </ul>
          
          <ul class="list-unstyled float col-md-5">
            <h5 data-i18n="docu.usage"></h5>
            {if($uses) then $uses ! 
            <li>
              <a href="{$ui:prefix}/inspection/module/{xs:hexBinary(hash:md5(./xd:module/xd:uri/string()))}/{$lng}"><span class="glyphicon glyphicon-import"></span>&#160;{./xd:module/xd:uri/string()}</a>
            </li>
            else <li data-i18n="docu.nousage"></li>}
          </ul>
          <ul class="list-unstyled float col-md-10">
            <h5 data-i18n="docu.ns"></h5>
            {if($namespaces) then 
              <table>
                <thead>
                  <td></td>
                  <td><i data-i18n="docu.prefix"></i></td>
                  <td><i data-i18n="docu.uri"></i></td>
                </thead>
                {$namespaces ! 
                  <tr>
                    <td style="width:2%"><i class="glyphicon glyphicon-import"/></td>
                    <td style="width:10%">{./@prefix/string()}</td>
                    <td style="width:70%">{./@uri/string()}</td>
                  </tr>}
              </table>
            else <li data-i18n="docu.nons"></li>
            }
          </ul>
          <ul class="list-unstyled float col-md-5">
            <h5 data-i18n="docu.variables"></h5>
            {if($variables) then $variables ! 
            <li>
              <span class="glyphicon glyphicon-import"></span>&#160;{./xd:name/string()}&#160;({./xd:type/string()})
            </li>
            else <li data-i18n="docu.novariables"></li>
            }
          </ul>
          <ul class="list-unstyled float col-md-11">
            <h5 data-i18n="docu.func"></h5>
              {if($functions) then 
                <div id="functions-list" class="float col-md-11">                
                  <table class="table noindent">
                  <thead>
                     <tr style="cursor:default">
                       <th class="vertical-middle" style="width:20%" data-i18n="docu.func"></th>
                       <th class="vertical-middle" style="width:20%" data-i18n="docu.para"></th>
                       <th class="vertical-middle" style="width:20%"></th>
                       <th class="vertical-middle" style="width:20%" data-i18n="docu.doc"></th>
                     </tr>
                   </thead>
                   <tbody>
                     {for $function in $functions 
                     return page:function-item($function)}
                   </tbody>
                  </table>
                </div>
              else <li data-i18n="docu.nofunc"></li>}
           </ul>
        </div>
        
        else <div data-i18n="docu.nomodul"></div>
        ,<div class="col-md-12"><a class="btn btn-cm bpm-btn" href="{$ui:prefix}/inspection/{$lng}" data-i18n="docu.back"></a></div>
};

(:~
 : Diese Funktion Formatiert den String der Signatur einer Funktion.
 : @param $signature Signatur der Funktion
 : @return Formatierte Signatur
:)
declare function page:format-signature($signature) {
  let $matches := functx:get-matches-and-non-matches($signature,"%")
  return <div>
          {for $match in $matches return 
          if(starts-with($match,"%")) then (
            if(contains($match/string()," function ")) then 
            (let $split := tokenize($match/string()," function ") return ($split[1],<br/>," function ",$split[2])) 
            else $match/string())  
          else ($match/string(),<br/>)}
         </div>
};

(:~
 : Diese Funktion generiert eine HTML Tabellen-Zeile, welche die Dokumentation einer XQuery-Funktion anzeigt.
 : @param $function Funktion des Xquery-Moduls
 : @return Tabellen-Zeile der Funktion
:)
declare function page:function-item($function) {
  let $name := $function/xd:name/string()
  let $arity := $function/@arity/string()
  let $signature := $function/xd:signature/string()
  let $description := $function/xd:comment/xd:description/string()
  let $parameters := $function/xd:parameters/xd:parameter
  let $annotations := $function/xd:annotations/xd:annotation
  return (
  <tr onclick="" style="cursor:pointer" class="accordion-toggle {if($description) then 'success' else 'danger'}" data-toggle="collapse" data-target="#function{xs:hexBinary(hash:md5($signature))}">
    <td class="vertical-middle" style="width:40%">{$name}</td>
          
          <td class="vertical-middle" style="width:20%">{$arity}</td>
          
          <td class="vertical-middle" style="width:20%">{if($annotations[@name="updating"]) then "updating" else ()}</td>
          <td class="vertical-middle" style="width:20%">{if(inspection:validate-function($function)) then <i class="glyphicon glyphicon-remove-sign" style="color:red"/> else <i class="glyphicon glyphicon-ok-sign success" style="color:green"/>}</td>
    
  </tr>
  ,<tr>
      <td colspan="5" class="hiddenRow">
          <div class="accordion-body collapse" id="function{xs:hexBinary(hash:md5($signature))}">
            {page:function-inner($function)}
          </div>
      </td>
   </tr>)
};

(:~
 : Diese Funktion generiert den Inhalt unter der Tabellenzeile, der in der Ansicht aufgeklappt werden kann.
 : @param $function Funktion des XQuery-Moduls
 : @return Inhalt der Dokumentation der Funktion
:)
declare function page:function-inner($function) {
  let $signature := page:format-signature($function/xd:signature/string())
  let $description := $function/xd:comment/xd:description/string()
  let $parameters := $function/xd:parameters/xd:parameter
  let $annotations := $function/xd:annotations/xd:annotation
  let $return := $function/xd:comment/xd:return/string()
  let $return-type := $function/xd:return/string()
  let $function-code := ()
  return 
  <div>
    <ul class="list-unstyled float col-md-7">
      <h5 data-i18n="docu.desc"></h5>
      {if($description) then $description else <div style="color:red" data-i18n="docu.nodesc"></div>}
    </ul>
    <ul class="list-unstyled float col-md-11">
      <h5 data-i18n="docu.sig"></h5>
      {if($signature) then $signature else <div data-i18n="docu.nosig"></div>}
    </ul>
    {if(not($function/xd:annotations/xd:annotation[@name='updating']) or not($return=())) then <ul class="list-unstyled float col-md-11">
      <h5 data-i18n="docu.ret"></h5>
      {if($return) then (<span>{$return}</span>,<span>, <span data-i18n="docu.type"></span>: {$return-type}</span>) else <div style="color:red"  data-i18n="docu.noret"></div>}
    </ul> else ()}
    
    {if($parameters) then <div id="parameters-list" class="float col-md-11"> 
      <h5 data-i18n="docu.para"></h5>
      {page:function-parameter-list($function)}
    </div> else ()}
    
    {if($annotations) then <div id="parameters-list" class="float col-md-11"> 
      <h5 data-i18n="docu.anno"></h5>
      {page:function-annotation-list($function)}
    </div> else ()}
    
    
  </div>
};

(:~
 : Diese Funktion generiert die Tabelle für die Anzeige der Parameter, die einer Funktion übergeben werden
 : @param $function Funkion des Xquery-Moduls
 : @return Tabelle der Parameterliste einer Funktion
:)
declare function page:function-parameter-list($function) {
  let $parameters := $function/xd:parameters/xd:parameter 
  return
  <table class="table table-condensed noindent">
    <thead>
       <tr style="cursor:default">
         <th class="vertical-middle" style="width:20%" data-i18n="docu.name"></th>
         <th class="vertical-middle" style="width:20%" data-i18n="docu.type"></th>
         <th class="vertical-middle" style="width:50%" data-i18n="docu.desc"></th>
         <th class="vertical-middle" style="width:10%" data-i18n="docu.doc"></th>
       </tr>
     </thead>
     <tbody>
       {for $parameter in $parameters 
       return page:function-parameter-item($function,$parameter)}
     </tbody>               
  </table>
};

(:~
 : Diese Funktion generiert eine Tabellen-Zeile für die Anzeige der Parameter, die einer Funktion übergeben werden
 : @param $function Funkion des Xquery-Moduls
 : @param $parameter Parameter der Funktion
 : @return Tabellen-Zeile der Parameterliste einer Funktion
:)
declare function page:function-parameter-item($function,$parameter) {
  let $name := $parameter/xd:name/string()
  let $type := $parameter/xd:type/string()
  let $occurrence := $parameter/xd:type/@occurrence/string() 
  let $description := $function/xd:comment/xd:param[starts-with(string(),"$"||$name||" ")]
  let $description := substring-after($description,"$"||$name||" ")
  return 
  <tr style="cursor:default" class="{if($description) then 'success' else 'danger'}">
    <td class="vertical-middle">{$name}</td>
    <td class="vertical-middle">{$type}{$occurrence}</td>
    <td class="vertical-middle">{if($description) then $description else <span data-i18n="docu.nodesc"></span>}</td>
    <td class="vertical-middle">{if(inspection:validate-parameter($function,$parameter)) then <i class="glyphicon glyphicon-remove-sign" style="color:red"/> else <i class="glyphicon glyphicon-ok-sign success" style="color:green"/>}</td>
  </tr>
};

(:~
 : Diese Funktion generiert die Tabelle für die Anzeige der Annotationen einer Funktion
 : @param $function Funkion des Xquery-Moduls
 : @return Tabelle der Annotationen einer Funktion
:)
declare function page:function-annotation-list($function) {
  let $annotations := $function/xd:annotations/xd:annotation 
  let $desctition := () 
  return
  <table class="table table-condensed noindent">
    <thead>
       <tr style="cursor:default">
         <th class="vertical-middle" style="width:20%" data-i18n="docu.name"></th>
         <th class="vertical-middle" style="width:80%" data-i18n="docu.val"></th>
       </tr>
     </thead>
     <tbody>
       {for $annotation in $annotations 
       return page:function-annotation-item($annotation)}
     </tbody>               
  </table>
};

(:~
 : Diese Funktion generiert eine Tabellen-Zeile für die Anzeige der Annotationen einer Funktion
 : @param $annotation Annotation einer Xquery-Funktion
 : @return Tabellen-Zeile einer Annotation einer Funktion
:)
declare function page:function-annotation-item($annotation) {
  let $description := ()
  let $name := $annotation/@name/string()
  let $type := $annotation/xd:literal/@type/string()
  let $value := $annotation/xd:literal/string() 
  let $search := ()
  return 
  <tr onclick="" style="cursor:default">
    <td class="vertical-middle">{$name}</td>
    <td class="vertical-middle">{$value}</td>    
  </tr>
};
