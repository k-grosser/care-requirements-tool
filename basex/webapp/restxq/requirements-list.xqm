(:~
 : Diese Modul generiert die Ansicht für die Anforderungsliste.
 : @version 1.0
 : @author Florian Eckey
 :)
module namespace page = 'masterthesis/modules/web-page/requirements-list';

import module namespace ui = 'masterthesis/modules/ui-manager';
import module namespace cm ="masterthesis/modules/care-manager";
import module namespace diff="masterthesis/modules/care/model-differences";
import module namespace util="masterthesis/modules/utilities";

(: view modules :)
import module namespace relistview="masterthesis/modules/care/view/list-view";

declare namespace c="care";

(:~
 : Diese Funktion erzeugt den HTML-Inhalt der Anforderungsliste zu einem bestimmten Prozess. Der Inhalt wird in das UI-Template eingebunden.  
 : @param $pkg-id Die ID des Paketes
 : @param $pkg-version Versions-ID des Prozesses
 : @return Anforderungsliste (XHTML)
 :)
declare
  %rest:path("requirements-manager/list/{$pkg-id}/{$pkg-version}/{$lng}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start($pkg-id, $pkg-version, $lng)
  as element(Q{http://www.w3.org/1999/xhtml}html) {
    ui:page($lng,
      <div class="container-fluid">
        <div class="col-md-12">
          {page:view-elements($pkg-id, $pkg-version)}
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
 : Diese Funktion erzeugt den HTML-Inhalt der Anforderungsliste aller Anfordeurngen. Der Inhalt wird in das UI-Template eingebunden.
 : @return Anforderungsliste (XHTML)
 :)
declare
  %rest:path("requirements-manager/list/{$lng}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start($lng)
  as element(Q{http://www.w3.org/1999/xhtml}html) {
    ui:page($lng,
      <div class="container-fluid">
        <div class="col-md-12">
          {page:view-elements()}
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
 : Diese Funktion generiert den Inhalt der Anforderungsliste als Tabelle. Sie erzeugt den Tabellenkopf und generiert 
 : für jede Anforderung in der care-packages Datenbank eine Zeile.
 : @return Tabelle der Anforderungen (XHTML)
 :)
declare function page:view-elements() {
  let $current-packages := 
     let $pkg-ids := distinct-values(for $path in db:list-details($cm:db-name) return substring-before($path,"/"))
     for $pkg-id in $pkg-ids
     let $packages := cm:get($pkg-id)
     return util:latest-element($packages)
  let $requirements := $current-packages/c:Activity/c:Requirements/c:Requirement return
  <div>
    {if(count($requirements)>0) then <table class="table noindent">
      <thead>
        <tr style="cursor:default">
          <th></th>
          <th>Anforderung</th>
          <th>Prozess</th>
          <th>Aktivität</th>
          <th style="width:2%"></th>
         </tr>
      </thead>
      <tbody>
      {for $package in $current-packages
         for $activity in $package/c:Activity
         let $requirements := $activity/c:Requirements/c:Requirement
           for $requirement in $requirements order by $requirement/@Timestamp descending return page:requirements-list-item($requirement)}
       </tbody>
    </table> 
    else 
      <div class="text-center"><b>keine Anforderungen erhoben</b></div>}
  </div>
};

(:~
 : Diese Funktion generiert den Inhalt der Anforderungsliste als Tabelle. Sie erzeugt den Tabellenkopf und generiert 
 : für jede Anforderung in dem übergebenen Prozess eine Zeile.
 : @param $pkg-id Die ID des Paketes
 : @param $pkg-version Versions-ID des Prozesses
 : @return Tabelle der Anforderungen (XHTML)
 :)
declare function page:view-elements($pkg-id, $pkg-version) {
  let $current-activities := cm:get($pkg-id,$pkg-version)/c:Activity
  let $requirements := $current-activities/c:Requirements/c:Requirement return
  <div>
    {if(count($requirements)>0) then <table class="table noindent">
      <thead>
        <tr style="cursor:default">
          <th></th>
          <th>Anforderung</th>
          <th>Prozess</th>
          <th>Aktivität</th>
          <th style="width:2%"></th>
         </tr>
      </thead>
      <tbody>
      {for $activity in $current-activities
       let $requirements := $activity/c:Requirements/c:Requirement
       let $re-package := cm:get($pkg-id,$pkg-version)
        let $reference := $re-package/c:Activity[@Id=$activity/@Id]
       for $requirement in $requirements order by $requirement/@Timestamp descending return page:requirements-list-item($requirement)}
       </tbody>
    </table> 
    else 
      <div class="text-center"><b>noch keine Anforderungen erhoben</b></div>}
  </div>
};

(:~
 : Diese Funktion generiert den Inhalt der Anforderungsliste als Tabelle. Sie erzeugt den Tabellenkopf und generiert 
 : für jede Anforderung in dem übergebenen Prozess eine Zeile.
 : @param $requirement Die Anforderung, zu der die Zeile generiert wird
 : @return Zeile einer Anforderung in der Anforderungsliste (XHTML)
 :)
declare function page:requirements-list-item($requirement) {   
  let $current-package := cm:get($requirement/@PackageId,$requirement/@PkgVersionId)
  let $activity := $current-package/c:Activity[@Id=$requirement/@ReferenceId]
  return
  if($requirement) then
    <tr id="list-item{$requirement/@Id}" class="re-row">
      <td>{$requirement/@Prefix/string()}</td>
      <td>
        {if($requirement/c:Condition/@Type=("event","logic")) then
          (<span class="re-condition">{
            if($requirement/c:Condition/@Type="event") then 
              (<span class="re-condition-conjunction">{$requirement/c:Condition[@Type="event"]/c:Conjunction/string()}</span>
              ,<span class="re-condition-subjectDescription">{$requirement/c:Condition[@Type="event"]/c:SubjectDescription/string()}</span>
              ,<span class="re-condition-subject">{$requirement/c:Condition[@Type="event"]/c:Subject/string()}</span>
              ,<span class="re-condition-verb">{$requirement/c:Condition[@Type="event"]/c:Verb/string()}</span>)
            else if($requirement/c:Condition/@Type="logic") then 
              (<span class="re-condition-conjunction">{$requirement/c:Condition[@Type="logic"]/c:Conjunction/string()}</span>
              ,<span class="re-condition-comparisonItem">{$requirement/c:Condition[@Type="logic"]/c:ComparisonItem/string()}</span>
              ,<span class="re-condition-comparisonOperator">{$requirement/c:Condition[@Type="logic"]/c:ComparisonOperator/string()}</span>
              ,<span class="re-condition-value">{$requirement/c:Condition[@Type="logic"]/c:Value/string()}</span>
              ,<span class="re-condition-verb">{$requirement/c:Condition[@Type="logic"]/c:Verb/string()}</span>)
            else ()},
           </span>
          ,<span class="re-liability" titel="rechtliche Verbindlichkeit">{$requirement/c:Liability/string()}</span>
          ,<span class="re-system">{$requirement/c:System/string()}</span>)
         else 
          (<span class="re-system">{$requirement/c:System/string()}</span>
          ,<span class="re-liability" titel="rechtliche Verbindlichkeit">{$requirement/c:Liability/string()}</span>)
        }
        <span class="re-actor">{$requirement/c:Actor/string()}</span>
        <span class="re-functionality" style="width:13%">{$requirement/c:Functionality/string()}</span>
        <span class="re-object-detail1">{$requirement/c:ObjectDetail1/string()}</span>
        <span class="re-object">{$requirement/c:Object/string()}</span>
        <span class="re-object-detail2">{$requirement/c:ObjectDetail2/string()}</span>
        <span class="re-processverb-detail">{$requirement/c:ProcessVerbDetail/string()}</span>
        <span class="re-processverb">{$requirement/c:ProcessVerb/string()}</span>
      </td>
      <td>{$current-package/@Name/string()}</td>
      <td>{$activity/c:ContextInformation/c:Name/string()}</td>
      <td style="width:2%"><a class="glyphicon glyphicon-pencil" style="cursor:pointer" href="{$ui:prefix}/requirements-manager/assist/{$current-package/@Id}/{$current-package/@VersionId}/{$activity/@Id}?req-id={$requirement/@Id}"/></td>
    </tr> 
  else ()
};