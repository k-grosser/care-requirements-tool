(:~
 : Diese Modul generiert die Ansicht für den Assistenten. Er besteht aus der Anzeige der Inkonsistenzen, 
 : der Kontextinformationen der Aktivität, der Schabloneneingabe und der Liste der  
 : Anforderungen der Aktivität.
 : @see masterthesis/modules/care/view/consistency-view (Anzeige der Inkonsistenzen)
 : @see masterthesis/modules/care/view/stancil-view (Schabloneneingabe)
 : @see masterthesis/modules/care/view/list-view (Liste der Anforderungen, die mit der Aktivität verknüpft sind)
 : @see masterthesis/modules/care/view/info-view (Kontextinformationen der Aktivität)
 : @version 1.1
 : @author Florian Eckey, Katharina Großer
 :)
module namespace page = 'masterthesis/modules/web-page/elicitation-assist';

import module namespace ui = 'masterthesis/modules/ui-manager';
import module namespace re ="masterthesis/modules/care/requirements-manager";
import module namespace util="masterthesis/modules/utilities";
import module namespace cm ="masterthesis/modules/care-manager";
import module namespace diff="masterthesis/modules/care/model-differences";
import module namespace consistencymanager = 'masterthesis/modules/consistency-manager';

(: view modules :)
import module namespace reconsistencyview="masterthesis/modules/care/view/consistency-view";
import module namespace restancilview="masterthesis/modules/care/view/stancil-view";
import module namespace relistview="masterthesis/modules/care/view/list-view";
import module namespace reinfoview="masterthesis/modules/care/view/info-view";

declare namespace c="care";


(:~
 : Diese Funktion erzeugt den HTML-Inhalt der Assistenzansicht. Es werden die einzelnen Panels zusammengesetzt.  Der Inhalt wird in das UI-Template eingebunden.
 : @param $pkg-id Die ID des Paketes, zu der die Aktivitätenliste angezeigt wird
 : @param $pkg-version Versions-ID des Paketes, zu der die Aktivitätenliste angezeigt wird
 : @param $ref-id Die ID der Aktivität, zu der der Assistent angezeigt wird
 : @param $req-id Ausgewählte ID der Anforderung, falls diese für die Bearbeitung angewählt wurde
 : @return Assistenz-Ansicht (XHTML)
 :)
declare
  %rest:path("requirements-manager/assist/{$pkg-id}/{$pkg-version}/{$ref-id}")
  %restxq:query-param("req-id","{$req-id}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start($pkg-id, $pkg-version, $ref-id, $req-id)
  as element(Q{http://www.w3.org/1999/xhtml}html) {
    let $current-package := cm:get($pkg-id,$pkg-version)
    let $compare-package := cm:get($pkg-id,cm:package-before($current-package)/@VersionId/string())
    let $inconsistencies := if($compare-package) then diff:Activity($compare-package/c:Activity[@Id=$ref-id]/c:ContextInformation,$current-package/c:Activity[@Id=$ref-id]/c:ContextInformation) else ()
    let $care-ref := cm:get($pkg-id, $pkg-version)/c:Activity[@Id=$ref-id]
    let $inconsistencies := consistencymanager:check-consistency($care-ref, $inconsistencies)
    return
    ui:page(
      <div class="container-fluid">
        <div class="col-md-12">
          {reconsistencyview:consistency-panel($current-package,$compare-package, $ref-id, $req-id, $inconsistencies)}
        </div>
        <div class="col-md-4">
            {reinfoview:info-panel($current-package,$compare-package, $ref-id, $req-id,$inconsistencies)}
        </div>
        <div class="col-md-8">
          {restancilview:stancil-panel($current-package,$compare-package, $ref-id,$req-id)}       
          {relistview:list-panel($current-package,$compare-package, $ref-id, $req-id, $inconsistencies)}
        </div>
        

        <div class="col-md-12">
          {page:buttons($current-package, $compare-package,$ref-id)}   
        </div>
        <script><![CDATA[
            $(function () {
              $('[data-toggle="tooltip"]').tooltip({html:'true'})
            })
        ]]></script>
      </div> 
    )
};

(:~
 : Diese Funktion die Vor- und Zurück-Buttons, um im Assistenten zwischen den Aktivitäten hin und herzuschalten und den Zurückbutton, um zur Aktivitätenliste zu gelangen.
 : @param $current-package Das akutelle Paket, zu dem die Assistenz-An angezeigt wird
 : @param $compare-package Das Paket, mit dem verglichen wird
 : @param $ref-id Die ID der Aktivität, zu der der Assistent angezeigt wird
 : @return Buttonleiste (XHTML)
 :)
declare function page:buttons($current-package, $compare-package,$ref-id) {
          let $data-set := cm:filter($current-package, $compare-package,$ref-id)
          let $next-element := util:next-ts($data-set,$data-set[@Id=$ref-id])
          let $prev-element := util:prev-ts($data-set,$data-set[@Id=$ref-id]) 
          return (
            if(util:index-of($data-set,$data-set[@Id=$ref-id])<count($data-set)) 
            then <div class="panel-btn pull-right">
                   <a href="{$ui:prefix}/requirements-manager/assist/{$current-package/@Id}/{$current-package/@VersionId}/{$next-element/@Id}" id="nextPage" class="fui-arrow-right pull-right"></a> 
                 </div> 
            else ()
            ,if(util:index-of($data-set,$data-set[@Id=$ref-id])>1) 
             then <div class="panel-btn">  
                   <a href="{$ui:prefix}/requirements-manager/assist/{$current-package/@Id}/{$current-package/@VersionId}/{$prev-element/@Id}" id="prevPage" class="fui-arrow-left"></a> 
                 </div> 
             else ()
            ,<div class="panel-btn back"> <a href="{$ui:prefix}/requirements-manager/package/{$current-package/@Id}/{$current-package/@VersionId}" id="prevPage">Zur Aktivitätenliste</a></div>
        )
};

(:~
 : Diese Funktion stellt den REST-Aufruf für das Löschen einer Anforderung in der Datenbank dar. Sie ruft eine Funktion im REPO auf, welche das Löschen übernimmt.
 : @param $pkg-id Die ID des Paketes
 : @param $pkg-version Versions-ID des Prozesses
 : @param $ref-id Die ID der Aktivität
 : @param $req-id ID der Anforderung
 : @return Redirekt auf die Assistenz-Ansicht
 :)
declare %restxq:path("relist/delete/{$pkg-id}/{$pkg-version}/{$ref-id}/{$req-id}")
        updating function page:requirements-delete-itemReq($pkg-id, $pkg-version, $ref-id,$req-id) {
         re:delete-requirement($pkg-id, $pkg-version, $ref-id, $req-id)
         ,db:output(<restxq:redirect>/requirements-manager/assist/{$pkg-id}/{$pkg-version}/{$ref-id}</restxq:redirect>)
};

(:~
 : Diese Funktion stellt den REST-Aufruf für das Einfügen einer Anforderung in die Datenbank dar. Sie ruft eine Funktion im REPO auf, welche das Einfügen übernimmt und leitet alle möglichen Werte aller Varianten an diese weiter.
 : @param $pkg-id ID des Paketes
 : @param $pkg-version-id Version des Paketes
 : @param $ref-id ID der Aktivität
 : @param $req-id ID der Anforderung
 : @param $template-type Variante der MASTER-Schablone (Funktional, Prozess, Umgebung, Eigenschaft)
 : @param $condition-type Typ der Bedingung 
 : @param $condition-comparisonItem Vergleichsobjekt-Baustein der Bedingung
 : @param $condition-comparisonOperator Vergleichsoperator der Bedingung
 : @param $condition-value Wert-Baustein der Bedingung 
 : @param $condition-event Subjekt der Bedingung (Ereignis)
 : @param $condition-actor Akteur der Bedingung
 : @param $event-object Objekt der Bedingung
 : @param $event-function Funktion referenziert in der Bedingung
 : @param $event-verb Prozesswort der Bedingung
 : @param $system System-Baustein der anforderung
 : @param $liability Priorität-Baustein der Anforderung
 : @param $actor Akteur-Baustein der Anforderung
 : @param $functionality Art der Funktionalität-Baustein der Anforderung
 : @param $object-detail1 Präzisierung 1-Baustein des Objekts
 : @param $object Objekt-Baustein der Anforderung
 : @param $object-detail2 Präzisierung 2-Baustein des Objekts
 : @param $processverb-detail Konkretisierungs-Baustein des Prozesswortes
 : @param $processverb Prozesswort-Baustein
 : @param $category Kategorie der Anforderung
 : @return Redirekt auf die Assistenz-Ansicht
 :)
declare %restxq:path("restancil/save/{$pkg-id}/{$pkg-version-id}/{$ref-id}")
        %restxq:POST
        %restxq:query-param("req-id","{$req-id}")   
        %restxq:query-param("template-type","{$template-type}","")   
        %restxq:query-param("type","{$condition-type}","")
        %restxq:query-param("comparisonItem","{$condition-comparisonItem}","")
        %restxq:query-param("comparisonOperator","{$condition-comparisonOperator}","")
        %restxq:query-param("value","{$condition-value}","")
        %restxq:query-param("event","{$condition-event}","")
        %restxq:query-param("event-actor","{$event-actor}","")
        %restxq:query-param("event-object","{$event-object}","")
        %restxq:query-param("event-function","{$event-function}","")
        %restxq:query-param("event-verb","{$event-verb}","")
        %restxq:query-param("logicexpression","{$logicexpression}","")
        %restxq:query-param("system","{$system}","System")
        %restxq:query-param("liability","{$liability}","muss")
        %restxq:query-param("actor","{$actor}","")
        %restxq:query-param("functionality","{$functionality}","")
        %restxq:query-param("object-detail1","{$object-detail1}","")
        %restxq:query-param("object","{$object}","")
        %restxq:query-param("object-detail2","{$object-detail2}","")
        %restxq:query-param("processverb-detail","{$processverb-detail}","")
        %restxq:query-param("processverb","{$processverb}","")
        %restxq:query-param("category","{$category}","")
        updating function page:save-requirement($pkg-id, $pkg-version-id, $ref-id, $req-id, $template-type, $condition-type, $condition-comparisonItem, $condition-comparisonOperator, $condition-value, $condition-event, $event-actor, $event-object, $event-function, $event-verb, $logicexpression, $system, $liability, $actor, $functionality, $object-detail1, $object, $object-detail2, $processverb-detail, $processverb, $category) {
          let $condition := switch($condition-type)
                             case "event" return re:new-condition-event($condition-event, $event-actor, $event-object)
                             case "logic" return re:new-condition-logic($condition-comparisonItem, $condition-comparisonOperator, $condition-value, $logicexpression)
                             case "timespan" return re:new-condition-timespan($logicexpression)
                             default return ()
           return
           re:save($pkg-id,$pkg-version-id,$ref-id,$req-id,$template-type,$condition,$system,$liability,$actor,$functionality,$object-detail1,$object,$object-detail2,$processverb-detail,$processverb,$category)
           ,db:output(<restxq:redirect>/requirements-manager/assist/{$pkg-id}/{$pkg-version-id}/{$ref-id}</restxq:redirect>)
};