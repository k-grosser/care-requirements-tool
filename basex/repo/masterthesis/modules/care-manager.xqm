(:~ 
 : Diese Modul kapselt die Datenbank "Requirements".
 :
 : @author   Florian Eckey, Katharina Großer
 : @version  1.0
 :)
module namespace cm ="masterthesis/modules/care-manager";

import module namespace xm = 'masterthesis/modules/xpdl-manager';
import module namespace util="masterthesis/modules/utilities";
import module namespace biz = 'masterthesis/modules/bizagi-manager';

declare namespace c ="care";
declare namespace xpdl="http://www.wfmc.org/2009/XPDL2.2";

declare variable $cm:db-name := "care-packages";

(:~
 : Diese Funktion gibt die Vereinigung der Aktivitäten der aktuellen Version und der vorgänger Version zurück.
 : @param $current-package Paket
 : @param $compare-package Paket, mit dem das $current-package verglichen wird
 : @param $ref-id Die ID der Aktivität
 : @return Vereinigung der Aktivitäten
:)
declare function cm:filter($current-package,$compare-package,$ref-id) {
   let $ds1 := $current-package/c:Activity
   let $ds2 := $compare-package/c:Activity
   let $ds := if($ds2) then ($ds1 | $ds2[not(@Id=($ds1/@Id))]) else $ds1[@PkgVersionId=$current-package/@VersionId]
   return $ds
};

(:~
 : Diese Funktion führt die Transformation von XPDL in das CARE-Format durch. 
 : @param $pkg XPDL
 : @param $pkg-version Version des XPDLs
 : @param $timestamp Timestamp der Transformation
 : @return CARE Package
:)
declare function cm:xpdl-to-care($pkg, $pkg-version, $timestamp) {
  let $activities := $pkg/xpdl:WorkflowProcesses/xpdl:WorkflowProcess/xpdl:Activities/xpdl:Activity[xpdl:Implementation/xpdl:Task]
  let $system-relevant-activities := $activities[*:ExtendedValues/*:ExtendedValue[@Name="systemrelevant" and string()="ja"]]
  return
  <Package Id="{$pkg/@Id}" VersionId="{$pkg-version}" Timestamp="{$timestamp}" Name="{$pkg/@Name}" xmlns="care">
    {for $act at $i in  $system-relevant-activities return cm:xpdl-to-care-act($pkg, $pkg-version, $act, $i)}
  </Package>
};

(:~
 : Diese Funktion führt die Transformation von XPDL in das CARE-Format für eine Aktivität durch. 
 : @param $pkg XPDL Paket
 : @param $pkg-version Version des Paketes
 : @param $act Aktivität
 : @param $i Nummer des Pakets
 : @return Aktivität in der CARE Datenstruktur (XML)
:)
declare function cm:xpdl-to-care-act($pkg, $pkg-version, $act, $i) {
  let $lanes := $pkg/xpdl:Pools/xpdl:Pool/xpdl:Lanes/xpdl:Lane 
  let $pools := $pkg/xpdl:Pools/xpdl:Pool
  let $dataObjects := $pkg/xpdl:WorkflowProcesses/xpdl:WorkflowProcess/xpdl:DataObjects/xpdl:DataObject
  let $dataStores := $pkg/xpdl:DataStores/xpdl:DataStore
  let $dataStoreReferences := $pkg/xpdl:WorkflowProcesses/xpdl:WorkflowProcess/xpdl:DataStoreReferences/xpdl:DataStoreReference
  let $attachedEvents := $pkg/xpdl:WorkflowProcesses/xpdl:WorkflowProcess/xpdl:Activities/xpdl:Activity[xpdl:Event/xpdl:IntermediateEvent/@IsAttached="true"]
  let $attachedEvent := $attachedEvents[xpdl:Event/xpdl:IntermediateEvent/@Target=$act/@Id]/xpdl:Event/xpdl:IntermediateEvent
  let $taskType := $act/xpdl:Implementation/xpdl:Task/xpdl:*[1]/name()
  return
  <Activity Id="{$act/@Id}" PackageId="{$pkg/@Id}" PkgVersionId="{$pkg-version}" Number="{$i}">
    <ContextInformation ActivityId="{$act/@Id}">
      <Name Id="{$act/@Id}NAME">{$act/@Name/string()}</Name>
      <Performer Id="{$act/@Id}PERF">{$lanes[@Id=$act/xpdl:Performers/xpdl:Performer]/@Name/string()}</Performer>
      <Participant Id="{$act/@Id}PART">{$pools[@Id=$act/xpdl:Participants/xpdl:Participant]/@Name/string()}</Participant>
      <TaskType Id="{$act/@Id}TYPE">{cm:get-tasktype-name(if($taskType) then $taskType else "None")}</TaskType>
      <DataObjectInputs>
        {for $doInput in $act/xpdl:DataObjectInput return <DataObjectInput Id="{$doInput/@Id}" State="{$dataObjects[@Id/string()=$doInput/@Id/string()]/@State}">{$dataObjects[@Id/string()=$doInput/@Id/string()]/@Name/string()}</DataObjectInput>}
      </DataObjectInputs>
      <DataObjectOutputs>
        {for $doOutput in $act/xpdl:DataObjectOutput return <DataObjectOutput Id="{$doOutput/@Id}" State="{$dataObjects[@Id=$doOutput/@Id]/@State}">{$dataObjects[@Id=$doOutput/@Id]/@Name/string()}</DataObjectOutput>}
      </DataObjectOutputs>
      <DataStoreInputs>
        {for $dsInput in $act/xpdl:DataStoreInput return <DataStoreInput Id="{$dsInput/@Id}" State="{$dsInput/@State}">{$dataStores[@Id=$dsInput/@Id]/@Name/string()}</DataStoreInput>}
      </DataStoreInputs>
      <DataStoreOutputs>
        {for $dsOutput in $act/xpdl:DataStoreOutput return <DataStoreOutput Id="{$dsOutput/@Id}" State="{$dsOutput/@State}">{$dataStores[@Id=$dsOutput/@Id]/@Name/string()}</DataStoreOutput>}
      </DataStoreOutputs>
      <Predecessors>
         {for $activity in xm:getPredecessorActivities($pkg,$act/@Id) return <Predecessor Id="{$activity/@Id}" Type="{xm:getActivityType($pkg, $activity/@Id)}" Performer="{xm:getLaneForActivity($pkg,$activity)/@Name}" Transition="{xm:get-transition-label-from-predecessor($pkg,$activity/@Id,$act/@Id)}">{$activity/@Name/string()}</Predecessor>}
      </Predecessors>
    </ContextInformation>
    <Requirements/>
  </Activity>
};

(:~
 : Diese Funktion liefert alle nachfolger Versionen des übergebenen Paketes.
 : @param $pkg CARE Paket
 : @return Nachfolger-Pakete 
:)
declare function cm:packages-after($pkg) {
  cm:get($pkg/@Id)[xs:dateTime(@Timestamp)>xs:dateTime($pkg/@Timestamp)]
};

(:~
 : Diese Funktion liefert alle vorgänger Versionen des übergebenen Paketes.
 : @param $pkg CARE Paket
 : @return Vorgänger-Pakete 
:)
declare function cm:packages-before($pkg) {
  cm:get($pkg/@Id)[xs:dateTime(@Timestamp)<xs:dateTime($pkg/@Timestamp)]
};

(:~
 : Diese Funktion liefert die vorgänger Version des übergebenen Paketes.
 : @param $pkg CARE Paket
 : @return Nachfolger-Paket
:)
declare function cm:package-before($pkg) {
    let $packages-before := cm:packages-before($pkg)
    let $max-timestamp := max(for $tmp in $packages-before/@Timestamp return xs:dateTime($tmp))
    return $packages-before[xs:dateTime(@Timestamp)=$max-timestamp]
};

(:~
 : Diese Funktion kopiert alle Anforderungen der vorgänger Version eines Prozesses in die aktuelle Version
 : @param $pkg CARE Paket
 : @return Modifiziertes Paket mit den Anforderungen des vorgänger Pakets
:)
declare function cm:transfer-requirements-from-pkg-before($pkg) {
  copy $modified:=$pkg modify (
    let $package-before := cm:package-before($modified)
    for $activity in $package-before/c:Activity[@Id=$modified/c:Activity/@Id]
      for $requirement in $activity/c:Requirements/c:Requirement return
        let $modified-requirement := copy $tmp:=$requirement modify (replace value of node $tmp/@PackageId with $modified/@Id
                                                                    ,replace value of node $tmp/@PkgVersionId with $modified/@VersionId) return $tmp
        return insert node $modified-requirement into $modified/c:Activity[@Id=$activity/@Id]/c:Requirements)
  return $modified
};

(:~
 : Diese Funktion importiert eine BizAgi Datei in die care-packages Datenbank. 
 : Dazu liest sie die Binärdatei, extrahiert das XPDL, erzeugt daraus das CARE-Format und speichert dies in der Datenbank.
 : @param $bizagi BizAgi Binär-Datei
:)
declare updating function cm:import-bizagi($bizagi) {
  let $xpdl-packages := biz:read($bizagi)
        for $xpdl-package in $xpdl-packages 
        let $pkg-version := random:uuid()
        let $timestamp := current-dateTime()
        let $care-package := cm:xpdl-to-care($xpdl-package, $pkg-version, $timestamp)
        return (cm:save($care-package))
};

(:~
 : Diese Funktion importiert eine XPDL Datei in die care-packages Datenbank. Dazu erzeugt sie aus dem XDPL das CARE-Format und speichert dies in der Datenbank.
 : @param $xpdl XPDL
:)
declare updating function cm:import-xpdl($xpdl) {
  let $xpdl-package := parse-xml(convert:binary-to-string($xpdl))
  let $pkg-version := random:uuid()
  let $timestamp := current-dateTime()
  let $care-package := cm:xpdl-to-care($xpdl-package, $pkg-version, $timestamp)
  return (cm:save($care-package))
};

(:~
 : Diese Funktion speichert ein CARE-Paket in der care-packages Datenbank
 : @param $care-package CARE Paket
:)
declare updating function cm:save($care-package) {
  let $modified-package := cm:transfer-requirements-from-pkg-before($care-package)
  let $pkg-id := $care-package/@Id
  let $pkg-version := $care-package/@VersionId
  let $db-path := $pkg-id || "/" || $pkg-version || "/References.care" return 
  if(db:exists($cm:db-name,$db-path)) then ()
  else db:add($cm:db-name,$modified-package,$db-path)
};

(:~
 : Diese Funktion löscht eine CARE-Paket aus der care-packages Datenbank
 : @param $pkg-id ID des CARE Pakets
:)
declare updating function cm:delete-package($pkg-id) {
  let $db-path := $pkg-id
  return db:delete($cm:db-name, $db-path)
};

(:~
 : Diese Funktion löscht die Version eines Prozesses aus der care-packages Datenbank
 : @param $pkg-id ID des CARE Pakets
 : @param $pkg-version Version des CARE Pakets
:)
declare updating function cm:delete-package($pkg-id, $pkg-version) {
  let $db-path := $pkg-id || "/" || $pkg-version
  return db:delete($cm:db-name, $db-path)
};

(:~
 : Diese Funktion liefert einen Prozess aus der Datenbank
 : @param $pkg-id ID des CARE Pakets
 : @param $pkg-version Version des CARE Pakets
 : @return CARE Paket
:)
declare function cm:get($pkg-id, $pkg-version) {
  if($pkg-id and $pkg-version) then
    let $db-path := $cm:db-name || "/" || $pkg-id || "/" || $pkg-version || "/References.care"
    return doc($db-path)/*
  else ()
};

(:~
 : Diese Funktion liefert alle Prozesse eines Paketes aus der Datenbank
 : @param $pkg-id ID des CARE Pakets
 : @return CARE Prozess
:)
declare function cm:get($pkg-id) {
  if($pkg-id) then
    for $path in db:list-details($cm:db-name,$pkg-id)
    return if(db:exists($cm:db-name,$path)) then db:open($cm:db-name,$path)/* else ()
  else ()
};

(:~
 : Diese Funktion liefert alle Prozesse aller Pakete aus der Datenbank
 : @return CARE Prozesse
:)
declare function cm:get() {
  for $path in db:list-details($cm:db-name)/string()
  return db:open($cm:db-name,$path)/*
};

(:~
 : Translates XPDL task types to BPMN task types
 : @param $type XPDL task type
 : @return BPMN (like) task type name ('usertask', 'servicetask', 'receivetask', 'sendtask', 'scriptask', 'manualtask', 'businessruletask', or 'untypedtask')
:)
declare function cm:get-tasktype-name($type) {
  switch($type)
    case "TaskUser" return "usertask"
    case "TaskService" return "servicetask"
    case "TaskReceive" return "receivetask"
    case "TaskSend" return "sendtask"
    case "TaskScript" return "scripttask"
    case "TaskManual" return "manualtask"
    case "TaskBusinessRule" return "businessruletask"
    case "None" return "untypedtask"
    default return ()
};

(:~
 : Diese Funktion berechnet den Änderungs-Typ (update, create, delete) einer Aktivität in der care-packages Datenbank
 : @param $current-package CARE Paket
 : @param $compare-package Paket, mit dem das $current-package verglichen wird
 : @param $act Aktivität
 : @return Änderungs-Typ
 :)
declare function cm:change-type($current-package,$compare-package,$act) {
  if($current-package/c:Activity[@Id=$act/@Id] and $compare-package/c:Activity[@Id=$act/@Id])
  then if(util:hash-eq($current-package/c:Activity[@Id=$act/@Id]/c:ContextInformation,$compare-package/c:Activity[@Id=$act/@Id]/c:ContextInformation))
       then "consistent"
       else "updated"
  else if($current-package/c:Activity[@Id=$act/@Id] and not($compare-package/c:Activity[@Id=$act/@Id]))
  then "created"
  else if(not($current-package/c:Activity[@Id=$act/@Id]) and $compare-package/c:Activity[@Id=$act/@Id])
  then "deleted"
  else "undefined"
};