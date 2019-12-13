(:~
 : Dieses Modul stellt Funktionen für die Generigung des HTML Inhalts für die Ansicht der Eingabe von Anforderungen in die SOPHIST Satzschablone für eine Aktivität zur Verfügung
 : @version 1.1
 : @author Florian Eckey, Katharina Großer
:)
module namespace view="masterthesis/modules/care/view/stancil-view";

import module namespace rsugg ="masterthesis/modules/care/suggestions";
import module namespace ui = 'masterthesis/modules/ui-manager';
import module namespace util="masterthesis/modules/utilities";

declare namespace c="care";

(:~
 : Diese Funktion generiert den HTML Inhalt für den Header des Panels, in dem die Eingabefelder für den Funktions-Master-Master der SOPHSIT Schablone dargestellt sind
 : @param $current-package Das Paket, zu dem die Kontextinformationen angezeigt werden
 : @param $compare-package Das Paket, mit dem die Kontextinformationen verglichen werden
 : @param $ref-id Die ID der Aktivität, zu der die Kontextinformationen angezeigt werden
 : @param $req-id Ausgewählte ID der Anforderung, falls diese für die Bearbeitung angewählt wurde
 : @return HTML-Panel für die Eingabe in die Schablone
 :)
declare function view:stancil-panel($current-package,$compare-package, $ref-id, $req-id, $lng) {
  <div class="collapse-panel re-collapse-panel stancil-panel-header">
    <div class="header" data-toggle="collapse" aria-expanded="false" aria-controls="collapseExample">
      <dl class="palette">
        <dt>Anforderungs - Schablone{ui:info-tooltip("elicit.template")}</dt>
      </dl>
    </div>
      <div class="collapse in" id="collapseStancil">
      {view:stancil-form($current-package,$compare-package, $ref-id, $req-id)}
    </div>
  </div>
};

(:~
 : Diese Funktion generiert den HTML Inhalt für das Panel, in dem die Eingabefelder für den Bedingungs-Master der SOPHSIT Schablone dargestellt sind
 : @param $current-package Das Paket, zu dem die Kontextinformationen angezeigt werden
 : @param $compare-package Das Paket, mit dem die Kontextinformationen verglichen werden
 : @param $ref-id Die ID der Aktivität, zu der die Kontextinformationen angezeigt werden
 : @param $requirement Anforderung, welche in der Schablone bearbeitet werden soll, falls gesetzt
 : @return HTML-Panel für die Eingabe in die Bedingung der Schablone
 :)
declare function view:stancil-form-condition($current-package,$ref-id, $requirement) {
  
  let $care-ref := $current-package/c:Activity[@Id=$ref-id] return (
  
  <span id="span-condition" style="{if($requirement and $requirement/c:Condition) then '' else 'display:none'}">
  
  <input type="hidden"  class="re-input" id="type" name="type" value="{$requirement/c:Condition/@Type}"/>
  
  <span id="span-condition-event" style="{if($requirement and $requirement/c:Condition/@Type='event') then '' else 'display:none'}">
    <input type="text" id="conjunction" class="re-tooltip re-input re-condition re-disabled" style="width:5%;min-width:150px" disabled="true" value="Sobald"/>
    <input type="text" id="event-description" class="re-tooltip re-input re-condition re-disabled" style="width:7%;min-width:150px" disabled="true" value="das Ereignis"/>
    
    {ui:autocomplete-search-bar(
        rsugg:possible-events($care-ref)
        ,<input type="text" id="event" name="event" tabindex="1" placeholder="&#60;Ereignis&#62;" class="re-tooltip re-input re-condition" style="width:15%;min-width:150px" data-content="{view:info-tooltip('event')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition[@Type='event']/c:Subject/string() else ()}"/>)}
        
        <input type="text" id="verb" class="re-tooltip re-input re-condition re-disabled" style="width:5%;min-width:100px" disabled="true" value="eintritt"/>
        
  </span>
  
  <span id="span-condition-logic" style="{if($requirement and $requirement/c:Condition/@Type='logic') then '' else 'display:none'}">
    
    <input type="text" id="conjunction" disabled="true" class="re-tooltip re-input re-condition re-disabled" style="width:5%;min-width:150px" value="Falls"/>
    
    {ui:autocomplete-search-bar(
        rsugg:possible-compareItems($care-ref)
        ,<input type="text" id="comparisonItem" name="comparisonItem" tabindex="1" placeholder="&#60;Entscheidung&#62;" class="re-tooltip re-input re-condition" style="width:15%;min-width:200px" data-content="{view:info-tooltip('gateway')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition[@Type='logic']/c:ComparisonItem/string() else ()}"/>)}
        
    {ui:autocomplete-search-bar(
        rsugg:possible-operators($care-ref),    
    <input type="text" id="comparisonOperator" name="comparisonOperator" tabindex="1" placeholder="&#60;Vergleichsoperator&#62;" class="re-tooltip re-input re-condition" style="width:5%;min-width:150px" data-content="{view:info-tooltip('operator')}" rel="tooltip" data-html="true" data-placement="top" value="{rsugg:possible-operators($care-ref)[1]}"/>)}
    
    {ui:autocomplete-search-bar(
        rsugg:possible-comparevalues($care-ref)
        ,<input type="text" id="value" name="value" tabindex="2" placeholder="&#60;Wert&#62;" class="re-tooltip re-input re-condition" style="width:7%;min-width:150px" data-content="{view:info-tooltip('comparevalue')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition[@Type='logic']/c:Value/string() else ()}"/>)}
    
    <input type="text" id="verb" class="re-tooltip re-input re-condition" style="width:5%;min-width:100px" disabled="true" value="ist"/>
  </span>
  
  <span id="span-condition-timespan" style="{if($requirement and $requirement/c:Condition/@Type='timespan') then '' else 'display:none'}">
    <input type="text" id="conjunction" disabled="true" class="re-tooltip re-input re-condition re-disabled" style="width:5%;min-width:150px" value="Solange"/>
    
    {ui:autocomplete-search-bar(
        rsugg:possible-stateobjects($current-package,$care-ref)
        ,<input type="text" id="state-object" name="state-object" tabindex="1" placeholder="&#60;Objekt&#8260;System&#62;" class="re-tooltip re-input re-condition" style="width:15%;min-width:150px;" data-content="{view:info-tooltip('state-object')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition[@Type='timespan']/c:Object/string() else ()}"/>)}
        
     <input type="text" id="statetag" tabindex="1" class="re-tooltip re-input re-condition re-disabled" style="width:5%;min-width:150px;" disabled="true" value="sich im Zustand"/>
        {ui:autocomplete-search-bar(
        rsugg:possible-states($care-ref)
        ,<input type="text" id="state" name="state" tabindex="1" placeholder="&#60;Zustand&#62;" class="re-tooltip re-input re-condition" style="width:15%;min-width:150px;" data-content="{view:info-tooltip('state')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition[@Type='timespan']/c:State/string() else ()}"/>)}
        <input type="text" id="verb" tabindex="1" class="re-tooltip re-input re-condition re-disabled" style="width:5%;min-width:150px;" disabled="true" value="befindet"/>
        
  </span>
  
  <span id="span-condition-process" style="{if($requirement and $requirement/c:Condition/c:Process) then '' else 'display:none'}">
  
   {ui:autocomplete-search-bar(
        rsugg:possible-eventactors($current-package,$care-ref)
        ,<input type="text" id="event-actor" name="event-actor" tabindex="1" placeholder="&#60;Akteur&#8260;System&#62;" class="re-tooltip re-input re-condition" style="width:15%;min-width:150px;" data-content="{view:info-tooltip('event-actor')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition/c:Process/c:Actor/string() else ()}"/>)}
        
    {ui:autocomplete-search-bar(
        rsugg:possible-eventobjects($current-package,$care-ref)
        ,<input type="text" id="event-object" name="event-object" tabindex="1" placeholder="&#60;Objekt&#62;" class="re-tooltip re-input re-condition" style="width:15%;min-width:150px;" data-content="{view:info-tooltip('event-object')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition/c:Process/c:Object/string() else ()}"/>)}  
        
        <input type="text" id="event-functiontag" tabindex="1" class="re-tooltip re-input re-condition re-disabled" style="width:5%;min-width:150px; display:none;" disabled="true" value="die Funktion"/>
        {ui:autocomplete-search-bar(
        rsugg:possible-functions($current-package,$care-ref)
        ,<input type="text" id="event-function" name="event-function" tabindex="1" placeholder="&#60;Funktion&#62;" class="re-tooltip re-input re-condition" style="width:15%;min-width:150px; display:none;" data-content="{view:info-tooltip('function')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition/c:Process/c:Function/string() else ()}"/>)}  
    
    {ui:autocomplete-search-bar(
        rsugg:possible-condition-processverbs($current-package,$care-ref)
        ,<input type="text" id="event-verb" tabindex="1" placeholder="&#60;Prozessverb&#62;" class="re-tooltip re-input re-condition" style="width:5%;min-width:150px" data-content="{view:info-tooltip('verb')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition/c:Process/c:Verb/string() else ()}"/>)}
  
  </span>
  
   {ui:autocomplete-search-bar(
        rsugg:possible-logicexpressions($care-ref)
        ,<input type="text" id="logicexpression" tabindex="1" placeholder="&#60;logische Aussage&#62;" class="re-tooltip re-input re-condition" style="width:5%;min-width:150px; {if($requirement and $requirement/c:Condition/c:LogicExpression) then '' else 'display:none'}" data-content="{view:info-tooltip('logicexpression')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Condition/c:LogicExpression/string() else ()}"/>)}
  
  <span>,</span>
  
</span>)
};

(:~
 : Diese Funktion generiert den HTML Inhalt für das Panel, in dem die Eingabefelder für den Funktions-Master-Master der SOPHSIT Schablone dargestellt sind
 : @param $current-package Das Paket, zu dem die Kontextinformationen angezeigt werden
 : @param $compare-package Das Paket, mit dem die Kontextinformationen verglichen werden
 : @param $ref-id Die ID der Aktivität, zu der die Kontextinformationen angezeigt werden
 : @param $req-id Ausgewählte ID der Anforderung, falls diese für die Bearbeitung angewählt wurde
 : @return HTML-Formular für die Eingabe in die Schablone
 :)
declare function view:stancil-form($current-package,$compare-package, $ref-id, $req-id) {
    let $care-ref := $current-package/c:Activity[@Id=$ref-id]
    let $requirement := $care-ref/c:Requirements/c:Requirement[@Id=$req-id]
    return
    <div id="stancil" class="panel-box stancil-panel">
      <form id="stancil-form" class="form" action="{$ui:prefix}/restancil/save/{$current-package/@Id}/{$current-package/@VersionId}/{$ref-id}?{if($req-id) then 'req-id='|| $requirement/@Id else ()}" method="post" autocomplete="off">
      
      <input type="hidden"  class="re-input" id="template-type" name="template-type" value="functional"/>
      
      
      <div class="pull-right">
        <ul class="pull-right template-select">
          <li><a id="" onclick="" tabindex=""><i class="glyphicon glyphicon-wrench"/></a></li>
          <li><a onclick="" tabindex=""><i class="glyphicon glyphicon-globe"/></a></li>
          <li><a onclick="" tabindex=""><i class="glyphicon glyphicon-dashboard"/></a></li>
          <li><a onclick="" tabindex=""><i class="glyphicon glyphicon-briefcase"/></a></li>
        </ul>
       </div>
      
          {view:stancil-form-condition($current-package,$ref-id,$requirement)}
          
          {ui:autocomplete-search-bar(
                  rsugg:possible-systems($current-package,$care-ref)
                  ,<input type="text" id="system" name="system" placeholder="&#60;System&#62;" class="re-tooltip re-input re-main" style="width:6%;min-width:150px" data-content="{view:info-tooltip('system')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:System/string() else rsugg:possible-systems($current-package,$care-ref)[1]/@Name}"/>)}
          
          {ui:autocomplete-search-bar(
              rsugg:possible-liabilities()
              ,<input type="text" id="liability" name="liability" placeholder="&#60;Verbindlichkeit&#62;" class="re-tooltip re-input re-main" style="width:6%;min-width:100px" data-content="{view:info-tooltip('liability')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Liability/string() else rsugg:possible-liabilities()[1]/@Name}"/>)}
              
          {ui:autocomplete-search-bar(
                  rsugg:possible-actors($care-ref)
                  ,<input type="text" id="actor" name="actor" tabindex="4" placeholder="{if($care-ref/c:ContextInformation/c:TaskType=('usertask')) then '&#60;Akteur&#62;' else '(kein Akteur)'}" class="re-tooltip re-input re-actor {if($care-ref/c:ContextInformation/c:TaskType=('usertask')) then ' re-main' else ''}" style="width:15%;min-width:200px; {if($care-ref/c:ContextInformation/c:TaskType=('usertask')) then '' else 'display:none;'}" data-content="{view:info-tooltip('actor')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Actor/string() else rsugg:possible-actors($care-ref)[1]/@Name}"/>)}
          
          {ui:autocomplete-search-bar( 
                  rsugg:possible-functionalities($care-ref)
                  ,<input type="text" id="functionality" name="functionality" tabindex="5" placeholder="{if($care-ref/c:ContextInformation/c:TaskType=('servicetask')) then '(autonome Systemaktivität)' else '&#60;Art der Funktionalität&#62;'}" class="re-tooltip re-input {if($care-ref/c:ContextInformation/c:TaskType=('servicetask')) then '' else ' re-main'}" style="width:15%;min-width:250px" data-content="{view:info-tooltip('functionality')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Functionality/string() else rsugg:possible-functionalities($care-ref)[1]/@Name}" onfocus="if($.trim($('#functionality').val())=='die Möglichkeit bieten')$('#actor').show().focus().val('{rsugg:possible-actors($care-ref)[2]/@Name}');else $('#actor').hide().focus().val('');"/>)}
          
          {ui:autocomplete-search-bar(
                  rsugg:possible-objectdetails1($current-package,$care-ref)
                  ,<input type="text" id="object-detail1" name="object-detail1" tabindex="5" placeholder="&#60;Welches? Welche? Welcher?&#62;" class="re-tooltip re-input re-object-detail" style="width:25%; {if($requirement and $requirement/c:ObjectDetail1/string()) then '' else 'display:none'}" data-content="{view:info-tooltip('object-detail1')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:ObjectDetail1/string() else ()}" autocomplete="off"/>)}
                  
          {ui:autocomplete-search-bar(
                  rsugg:possible-objects($care-ref)
                  ,<input type="text" id="object" name="object" tabindex="6" placeholder="&#60;Objekt&#62;" class="re-tooltip re-input re-main" style="width:28%;min-width:200px" data-content="{view:info-tooltip('object')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:Object/string() else rsugg:possible-objects($care-ref)[1]/@Name}"/>)}
                  

          
          {ui:autocomplete-search-bar(
                  rsugg:possible-objectdetails2($current-package,$care-ref)
                  ,<input type="text" id="object-detail2" name="object-detail2" tabindex="7" placeholder="&#60;Wessen?&#62;" class="re-tooltip re-input re-object-detail" style="width:18%; {if($requirement and $requirement/c:ObjectDetail2/string()) then '' else 'display:none'}" data-content="{view:info-tooltip('object-detail2')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:ObjectDetail2/string() else ()}"/>)}
                  
          {ui:autocomplete-search-bar(
                  rsugg:possible-processverbdetails($current-package,$care-ref)
                  ,<input type="text" id="processverb-detail" name="processverb-detail" tabindex="8" placeholder="&#60;Wann? Wo? Woher? Wohin?&#62;" class="re-tooltip re-input re-processverb-detail" style="width:20%; {if($requirement and $requirement/c:ProcessVerbDetail/string()) then '' else 'display:none'}" data-content="{view:info-tooltip('processverb-detail')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:ProcessVerbDetail/string() else()}"/>)}
           
           
                  
          {ui:autocomplete-search-bar(
                  rsugg:possible-processverbs($current-package,$care-ref)
                  ,<input type="text" id="processverb" name="processverb" tabindex="9" placeholder="&#60;Prozesswort&#62;" class="re-tooltip re-input re-main" style="width:20%" data-content="{view:info-tooltip('processverb')}" rel="tooltip" data-html="true" data-placement="top" value="{if($requirement) then $requirement/c:ProcessVerb/string() else rsugg:possible-processverbs($current-package,$care-ref)[1]/@Name}"/>)}
          
        {view:validation-div("Bitte füllen Sie die Schablone vollständig und korrekt aus.", "error")}  
        
        <p>
            {if($requirement) then (<a class="btn btn-sm btn-stancil" tabindex="11" onclick="submitRequirement()"><span class="fui-check"/> Anforderung bearbeiten</a>
            ,<a class="btn btn-sm btn-stancil" tabindex="11" href="{$ui:prefix}/requirements-manager/assist/{$current-package/@Id}/{$current-package/@VersionId}/{$ref-id}">Abbrechen</a>) else <a class="btn btn-stancil btn-sm" tabindex="11" onclick="submitRequirement()"><span class="fui-check"/> Anforderung eintragen</a>}
            
        </p>
      </form>
    </div>
    ,<script type="text/javascript" src="{$ui:prefix}/static/care/js/requirements_bindings.js"/>
};

(:~
 : Diese Funktion generiert den HTML Inhalt für das Panel, in dem die Validierung für den Funktions-Master-Master der SOPHSIT Schablone dargestellt sind
 : @param $message Die Validierungs-Nachricht, die angezeigt werden soll
 : @param $type Der Typ der Fehlermeldung (wird nicht verwendet)
 : @return HTML-Panel für die Validierung der Eingabe in die Schablone
 :)
declare function view:validation-div($message, $type) {
  <div class="validation">
      {$message}<a id="validation-close" class="glyphicon glyphicon-remove validation-close pull-right"/>
  </div>
};

(:~
 : Diese Funktion generiert den HTML Inhalt ein Tooltip, welches über jedem Baustein der Schablone angezeigt wird, in dem sich zusätzliche Informationen zu dem Baustein befinden
 : @param $element Art des Schablonen-Bausteins, zu dem die Informationen angezeigt werden sollen
 : @return HTML-Tooltip
 :)
declare function view:info-tooltip($element as xs:string) {
  let $content :=
    switch($element)
      case "system" return 
        <div>Tragen Sie das System ein, für das die Anforderung erhoben wird. Ist ggf. ein Bedingungssatz erforderlich? Ein auslösendes <a id="condition-link" style="cursor:pointer" onclick="showEventCondition();if($('#span-condition-logic').is(':visible')) hideLogicCondition()">Ereignis</a> (Strg + b) oder eine <a id="condition-logic-link" style="cursor:pointer" onclick="showLogicCondition();if($('#span-condition-event').is(':visible')) hideEventCondition()">logische Bedingung</a> (erneut Strg + b)?</div>
        
      case "liability" return <div>Tragen Sie eine Verbindlichkeit der Anforderung ein. Wie wichtig ist diese für das Zielsystem?</div>   
      
      case "actor" return <div>Falls es sich um eine usertask handelt (&quot;die Möglichkeit bieten&quot;), tragen Sie einen zuständigen Akteur für die Anforderung ein. Dieser lässt sich aus der Rolle der Aktivität herleiten.</div>  
      
      case "functionality" return <div>Tragen Sie eine Funktionalität. Wird vom System eine Aktion automatisch ausgeführt (leer lassen) oder agiert ein Akteur (&quot;die Möglichkeit bieten&quot;)? Dies lässt sich aus dem Typ der Aktivität herleiten.</div> 
      
      case "object" return <div>Tragen Sie das Objekt ein, um das es in der Anforderung geht. Dies lässt sich aus den Dokumenten oder dem Namen der Aktivität herleiten. Können Sie das Objekt <span id="object-in-tooltip" style="color:green"></span> präzisieren? Fragen Sie nach <a id="object-detail1-link" onclick="$('#object-detail1').toggle().focus().val('');$('#object-detail1-in-tooltip').html($('#object').val())">Welches? Welche? Welcher?</a> oder <a id="object-detail2-link" onclick="$('#object-detail2').toggle().focus().val('');$('#objcet-detail2-in-tooltip').html($('#object').val())">Wessen?</a> (Strg + Leer)</div> 
      
      case "object-detail1" return <div>Präzisieren Sie das Objekt <span id="object-detail1-in-tooltip" style="color:green"></span>. <a onclick="$('#object-detail1').toggle().val('')"><i class="glyphicon glyphicon-remove pull-right"/></a></div>   
      
      case "object-detail2" return <div>Präzisieren Sie das Objekt <span id="object-detail2-in-tooltip" style="color:green"></span>. <a onclick="$('#object-detail2').toggle().val('')"><i class="glyphicon glyphicon-remove pull-right"/></a></div>
      
      case "processverb" return <div>Was wird in Anforderung von dem System verlangt? <span id="processverb-in-tooltip" style="color:green"></span>. Fragen Sie nach <a id="processverb-detail-link" onclick="$('#processverb-detail').toggle().focus().val('');$('#processverb-detail-in-tooltip').html($('#processverb').val())">Wann? Wo? Woher? Wohin?</a> (Strg + Leer)</div> 
      
      case "processverb-detail" return <div>Konkretisieren Sie das Prozesswort <span id="processverb-detail-in-tooltip" style="color:green"></span>. <a onclick="$('#process-detail').toggle().val('')"><i class="glyphicon glyphicon-remove pull-right"/></a></div>
      
      case "event" return <div>Welches Ereignis muss eintreten, damit die Anforderung, welche im Hauptsatz formuliert ist, greift? Wollen Sie den <a id="event-details-link" onclick="$('#event-description').hide();$('#event').hide().val('');$('#span-condition-process').show();$('#verb').hide();">Ereignis-Prozess</a> detaillierter Beschreiben?</div>
      
      case "gateway" return <div>Welche Entscheidungsparameter oder welche Frage ist Basis der Entscheidung?</div>
      
      case "comparevalue" return <div>Welche Entscheidung muss getroffen werden, damit die Anforderung greift? Dies Lässt sich aus dem Label der Transistion von dem vorherigen Gateway herleiten</div>
      
       case "event-actor" return <div>Welcher Akteur oder welches System löst das Ereignis aus? Kann oft aus der Rolle des Vorgängers abgeleitet werden. <a onclick="$('#span-condition-process').hide();$('#event-actor').val('');$('#event-object').val('');$('#event-function').hide().val('');$('#event-functiontag').hide();$('#event-description').show();$('#event').show();$('#verb').show();"><i class="glyphicon glyphicon-remove pull-right"/></a></div>
       
      case "event-object" return <div>Um welches Objekt geht es im Ereignis? Kann oft aus den Dokumenten oder dem Namen des Vorgängers abgeleitet werden. Oder ist das Objekt eine <a id="event-function-link" onclick="$('#event-object').hide().val('');$('#event-function').show();$('#event-functiontag').show();">Funktion</a>? <a onclick="$('#span-condition-process').hide();$('#event-actor').val('');$('#event-object').val('');$('#event-function').hide().val('');$('#event-functiontag').hide();$('#event-description').show();$('#event').show();$('#verb').show();"><i class="glyphicon glyphicon-remove pull-right"/></a></div>
      
      case "function" return <div>Um welches Funktion geht es im Ereignis? Kann oft aus dem Vorgänger abgeleitet werden. Oder ist es doch ein <a id="event-function-link" onclick="$('#event-object').show();$('#event-function').hide().val('');$('#event-functiontag').hide();">Objekt</a>? <a onclick="$('#span-condition-process').hide();$('#event-actor').val('');$('#event-object').val('');$('#event-function').hide().val('');$('#event-functiontag').hide();$('#event-description').show();$('#event').show();$('#verb').show();"><i class="glyphicon glyphicon-remove pull-right"/></a></div>
      
      case "event-verb" return <div>Was passiert in dem Ereignis? Was ist das Prozessverb? Bei auslösenden Ereignissen ist dieses in der Vergangenheitsform.</div>
      
      case "operator" return <div></div>
      
      case "logicexpression" return <div></div>
      
      default return "Kein Tooltip"
      
  return util:serialize-html($content)
};