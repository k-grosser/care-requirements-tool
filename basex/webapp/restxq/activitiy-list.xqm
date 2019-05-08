(:~
 : Activity list view, listing all activities of the selected process 
 : @author Florian Eckey, Katharina Großer
 : @version 1.1
 :)
module namespace page = 'masterthesis/modules/web-page/activity-list';

import module namespace ui = 'masterthesis/modules/ui-manager';
import module namespace cm ="masterthesis/modules/care-manager";
import module namespace diff="masterthesis/modules/care/model-differences";
import module namespace consistencymanager = 'masterthesis/modules/consistency-manager';

declare namespace c ="care";

(:~
 : Generates the activity list to be embedded into the GUI template
 : @param $pkg-id package ID of selected package to show activities of
 : @param $version-id version ID of the selected package
 : @return activity list view (XHTML)
 :)
declare
  %rest:path("requirements-manager/package/{$pkg-id}/{$version-id}/{$lng}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start($pkg-id, $version-id, $lng)
  as element(Q{http://www.w3.org/1999/xhtml}html) {
    let $current-package := cm:get($pkg-id,$version-id)
    let $compare-package := cm:package-before($current-package)
    let $compare-pkg-version := $compare-package/@VersionId/string()
    return
    ui:page($lng,
      <div class="container-fluid">
        <div class="col-md-12">
          <h5 data-i18n="activitylist.activitylist"></h5>        
        </div>
        <div class="col-md-8">
          {page:requirements-list($current-package, $compare-package, $lng)}
        </div>
        <div class="col-md-4">
        </div>
      </div>
    )
};

(:~
 : Diese Funktion generiert den Inhalt der Liste als Tabelle. Sie erzeugt den Tabellenkopf und generiert für jede Aktivität in der care-packages Datenbank eine Zeile.
 : @param $compare-package Das aktuelle Paket, welches die Aktivitäten und deren Kontextinformationen enthält
 : @param $current-package Die vorgänger Version des aktuellen Paketes
 : @see Funktion page:start
 : @return Tabelle der Aktivitätenliste (XHTML)
 :)
declare function page:requirements-list($current-package, $compare-package, $lng) {
            let $current-activities := $current-package/c:Activity
            let $compare-activities := $compare-package/c:Activity
            let $activities := if($compare-package) then ($current-activities | $compare-activities[not(@Id=$current-activities/@Id)]) else $current-activities
            return
            if($activities) then (
               <div id="requirementsList">
                  <table class="table table-hover noindent">
                     <thead>
                        <tr>
                           <th style="width:4%"></th>
                           <th class="col-md-1"><b data-i18n="activitylist.activity"></b>&#160;<span class="badge">{count($activities)}</span></th>
                           <th class="col-md-4"><b data-i18n="activitylist.reqs"></b></th>
                        </tr>
                     </thead>
                     <tbody>
                        {for $activitiy in $activities return
                           page:list-item($compare-package,$current-package,$activitiy,$lng)}                     
                     </tbody>      
                  </table>
               </div>) 
            else (<div id="requirementsList" data-i18n="activitylist.noactivity"></div>)
};

(:~
 : Diese Funktion generiert die Differenzansicht des Namens einer Aktivität in der Aktivitätenliste
 : @param $compare-package Das aktuelle Paket, welches die Aktivitäten und deren Kontextinformationen enthält
 : @param $current-package Die vorgänger Version des aktuellen Paketes
 : @param $reference Die Aktivität, zu der die Differenzansicht berechnet wird
 : @param $inconsistencies Die Inkonsistenzen, die für die übergebene Aktivität berechnet wurden
 : @see Funktion page:list-item
 : @return Differenzansicht des Namens einer Aktivität (XHTML)
 :)
declare function page:activity-name($compare-package, $current-package, $reference, $inconsistencies) {
  let $change-type := cm:change-type($current-package, $compare-package, $reference) return 
  if($compare-package) then 
    switch($change-type)
      case "updated" return if($inconsistencies) then <span style="color:orange">
                               {$current-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation/c:Name/string()}
                             </span> else <span>
                               {$current-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation/c:Name/string()}
                             </span>
      case "deleted" return <span style="text-decoration: line-through;color:red">
                               {$compare-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation/c:Name/string()}
                             </span>
      case "created" return if(count($reference/c:Requirements/c:Requirement)=0) then <span style="color:green">
                               {$current-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation/c:Name/string()}
                            </span> else if($inconsistencies) then <span style="color:orange">
                               {$current-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation/c:Name/string()}
                             </span> else <span>
                               {$current-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation/c:Name/string()}
                             </span>
      default return <span>
                       {$current-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation/c:Name/string()}
                     </span>
  else <span>
         {$current-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation/c:Name/string()}
       </span>
};

(:~
 : Diese Funktion generiert eine Zeile der Tabelle der Liste als Tabelle der Aktivitätenliste.
 : @param $compare-package Das aktuelle Paket, welches die Aktivitäten und deren Kontextinformationen enthält
 : @param $current-package Die vorgänger Version des aktuellen Paketes
 : @param $reference Die Aktivität, zu der die Zeile generiert wird
 : @see Funktion page:requirements-list
 : @return Tabelle-Zeile der Aktivitätenliste (XHTML)
 :)
declare function page:list-item($compare-package, $current-package, $reference, $lng) {
  let $inconsistencies := if($compare-package) then diff:Activity($compare-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation,$current-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation) else ()
  let $care-ref := cm:get($current-package/@Id, $current-package/@VersionId)/c:Activity[@Id=$reference/@Id]
  let $inconsistencies := consistencymanager:check-consistency($care-ref, $inconsistencies)
  let $diff-name := page:activity-name($compare-package, $current-package, $reference, $inconsistencies)
  let $change-type := cm:change-type($current-package, $compare-package, $reference)
  let $name := $current-package/c:Activity[@Id=$reference/@Id]/c:ContextInformation/c:Name/string() return 
    if($compare-package) then
      if($current-package/c:Activity[@Id=$reference/@Id]) then 
        <tr onclick="window.location='{$ui:prefix}/requirements-manager/assist/{$reference/@PackageId}/{$reference/@PkgVersionId}/{$reference/@Id}/{$lng}'" style="cursor:pointer">
          <td class="th-info" id="validation{$reference/@Id}" style="width:4%">
            {switch($change-type)
              case "updated" return if($inconsistencies) then <i data-i18n="[title]activitylist.changes" class="glyphicon glyphicon-warning-sign text-warning" style="cursor:default;"/> else ()
              case "deleted" return <i class="glyphicon glyphicon-minus-sign text-danger" style="cursor:default;" data-i18n="[title]activitylist.deleted"/>
              case "created" return if(count($reference/c:Requirements/c:Requirement)=0) then <i class="glyphicon glyphicon-plus-sign text-success" style="cursor:default;" data-i18n="[title]activitylist.add"/> else if($inconsistencies) then <i data-i18n="[title]activitylist.changes" class="glyphicon glyphicon-warning-sign text-warning" style="cursor:default;"/> else ()
              default return ()}
          </td>
          <td class="col-md-7">{$diff-name}</td>
          <td class="col-md-1"><span class="badge" style="{if(count($reference/c:Requirements/c:Requirement)=0) then 'background-color:orange' else ()}">{count($reference/c:Requirements/c:Requirement)}</span></td>
        </tr>
      else
        <tr onclick="window.location='{$ui:prefix}/requirements-manager/assist/{$reference/@PackageId}/{$reference/@PkgVersionId}/{$reference/@Id}/{$lng}'" style="cursor:pointer">
          <td class="th-info" id="validation{$reference/@Id}" style="width:4%">
            {switch($change-type)
              case "updated" return if($inconsistencies) then <i data-i18n="[title]activitylist.changes" class="glyphicon glyphicon-warning-sign text-warning" style="cursor:default;"/> else ()
              case "deleted" return <i class="glyphicon glyphicon-minus-sign text-danger" style="cursor:default;" data-i18n="[title]activitylist.deleted"/>
              case "created" return if(count($reference/c:Requirements/c:Requirement)=0) then <i class="glyphicon glyphicon-plus-sign text-success" style="cursor:default;" data-i18n="[title]activitylist.add"/> else if($inconsistencies) then <i data-i18n="[title]activitylist.changes" class="glyphicon glyphicon-warning-sign text-warning" style="cursor:default;"/> else ()
              default return ()}
          </td>
          <td class="col-md-7">{$diff-name}</td>
          <td class="col-md-1"></td>
        </tr>
      else 
        <tr onclick="window.location='{$ui:prefix}/requirements-manager/assist/{$reference/@PackageId}/{$reference/@PkgVersionId}/{$reference/@Id}/{$lng}'" style="cursor:pointer">
          <th style="width:4%"></th>
          <td class="col-md-7">{$diff-name}</td>
          <td class="col-md-1"><span class="badge" style="{if(count($reference/c:Requirements/c:Requirement)=0) then 'background-color:orange' else ()}">{count($reference/c:Requirements/c:Requirement)}</span></td>
        </tr>
};