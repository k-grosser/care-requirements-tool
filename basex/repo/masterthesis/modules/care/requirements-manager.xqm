(:~ 
 : Diese Modul stellt alle Funktionen bereit, welche das CARE-Datenformat verarbeiten.
 : @author   Florian Eckey
 : @version 1.1
 :)
module namespace re ="masterthesis/modules/care/requirements-manager";

import module namespace cm ="masterthesis/modules/care-manager";

declare namespace c ="care";

(:~
 : Diese Funktion generiert das XML Element einer Bedingung nach dem LogikMaster
 : @param $comparison-item Vergleichobjekt-Baustein der Bedingung
 : @param $condition-comparisonOperator Vergleichsoperator der Bedingung
 : @param $value Wert-Baustein der Bedingung
 : @param $logicexpression Logischer Ausdruck - Alternativ zur Prozessbeschreibung
 : @return XML der Bedingung
:)
declare function re:new-condition-logic($comparison-item, $condition-comparisonOperator, $value, $logicexpression) {
  if ($logicexpression = '') then
  <Condition Type="logic">
    <Conjunction>Falls</Conjunction>
    <ComparisonItem>{$comparison-item}</ComparisonItem>
    <ComparisonOperator>{$condition-comparisonOperator}</ComparisonOperator>
    <Value>{$value}</Value>
    <Verb>ist</Verb>
  </Condition> 
 else
 <Condition Type="logic">
    <Conjunction>Falls</Conjunction>
    <Expression>{$logicexpression}</Expression>
  </Condition>
};

(:~
 : Diese Funktion generiert das XML Element einer Bedingung nach dem EreignisMaster
 : @param $event Ereignis-Baustein
 : @param $event-actor Akteur-Baustein für detaillierte Events
 : @param $event-object Objekt-Baustein für detaillierte Events
 : @return XML der Bedingung
:)
declare function re:new-condition-event($event, $event-actor, $event-object) {
  if ($event = '') then
  <Condition Type="event">
    <Conjunction>Sobald</Conjunction>
    <SubjectDescription>das Ereignis</SubjectDescription>
    <Subject>{$event}</Subject>
    <Verb>eintritt</Verb>
  </Condition>
  else
  <Condition Type="event">
    <Conjunction>Sobald</Conjunction>
    <Subject>{$event-actor}</Subject>
    <Verb>eintritt</Verb>
    <Object>{$event-object}</Object>
  </Condition>
};

(:~
 : Diese Funktion generiert das XML Element einer Bedingung nach dem ZeitraumMaster
 : @param $logicexpression Logische Aussage (Schleifenbedingung)
 : @return XML der Bedingung
:)
declare function re:new-condition-timespan($logicexpression) {
  <Condition Type="timespan">
    <Conjunction>Solange</Conjunction>
  </Condition>
};

(:~
 : Diese Funktion generiert das XML Element einer Anforderung nach SOPHIST Schablone durch Aufruf der überladenen Funktion mit automatisch generierter ID
 : @param $pkg-id ID des Paketes
 : @param $pkg-version-id Version des Paketes
 : @param $ref-id ID der Aktivität
 : @param $template-type Variante der MASTER-Schablone (Funktional, Prozess, Umgebung, Eigenschaft)
 : @param $condition Bedingung der Anforderung als XML
 : @param $system System-Baustein der anforderung
 : @param $liability Priorität-Baustein der Anforderung
 : @param $actor Akteur-Baustein der Anforderung
 : @param $functionality Art der Funktionalität-Baustein der Anforderung
 : @param $object-detail1 Präzisierung 1-Baustein des Objekts
 : @param $object Objekt-Baustein der Anforderung
 : @param $object-detail2 Präzisierung 2-Baustein des Objekts
 : @param $processverb-detail Konkretisierungs-Baustein des Prozesswortes
 : @param $processverb Prozesswort-Baustein
 : @param $category Kategorie der Anfordeurung
 : @return XML der Anforderung
:)
declare function re:new-requirement($pkg-id, $pkg-version-id, $ref-id, $template-type, $condition, $system, $liability, $actor, $functionality,$object-detail1, $object,$object-detail2,$processverb-detail, $processverb, $category) {
  
  let $new-requirement := re:new-requirement(random:uuid(),(),$pkg-id, $pkg-version-id, $ref-id, $template-type, $condition, $system, $liability, $actor, $functionality, $object-detail1,$object,$object-detail2,$processverb-detail, $processverb, $category)
  
  return $new-requirement
};

(:~
 : Diese Funktion generiert das XML Element einer Anforderung nach SOPHIST Schablone
 : @param $id ID der Anforderung
 : @param $nr Numer der Anforderung
 : @param $pkg-id ID des Paketes
 : @param $pkg-version-id Version des Paketes
 : @param $ref-id ID der Aktivität
 : @param $template-type Variante der MASTER-Schablone (Funktional, Prozess, Umgebung, Eigenschaft)
 : @param $condition Bedingung der Anforderung als XML
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
 : @return XML der Anforderung
:)
declare function re:new-requirement($id, $nr , $pkg-id, $pkg-version-id, $ref-id, $template-type, $condition, $system, $liability, $actor, $functionality,$object-detail1, $object,$object-detail2,$processverb-detail, $processverb, $category) {
  let $activity := cm:get($pkg-id,$pkg-version-id)/c:Activity[@Id=$ref-id]
  let $numbers := $activity/c:Requirements/c:Requirement/@Number
  let $number := if($numbers) then max($numbers) else 1 return
  <Requirement Id="{$id}" Type="functional" Timestamp="{current-dateTime()}" PackageId="{$pkg-id}" PkgVersionId="{$pkg-version-id}" ReferenceId="{$ref-id}" Number="{if($nr) then $nr else ($number + 1)}" Prefix="ANF-{$activity/@Number}-{$number + 1}">
    {$condition}
    {<System>{$system}</System>}
    <Liability>{$liability}</Liability>
    {<Actor>{$actor}</Actor>}
    <Functionality>{$functionality}</Functionality>
    <ObjectDetail1>{$object-detail1}</ObjectDetail1>
    {<Object>{$object}</Object>}
    <ObjectDetail2>{$object-detail2}</ObjectDetail2>
    <ProcessVerbDetail>{$processverb-detail}</ProcessVerbDetail>
    <ProcessVerb>{$processverb}</ProcessVerb>
  </Requirement>
};

(:~
 : Diese Funktion entfernt die Anforderung mit der übergebenen ID aus dem übergebenen Paket und Prozess
 : @param $pkg-id ID des Paketes
 : @param $pkg-version Version des Paketes
 : @param $ref-id ID der Aktivität
 : @param $req-id ID der Anforderung
:)
declare updating function re:delete-requirement($pkg-id, $pkg-version, $ref-id, $req-id) {
  let $pkg := cm:get($pkg-id,$pkg-version)
  let $packages-after := cm:packages-after($pkg)
  let $packages := $packages-after | $pkg
  for $package in $packages
    return delete node $package/c:Activity[@Id=$ref-id]/c:Requirements/c:Requirement[@Id=$req-id]
};

(:~
 : Diese Funktion speichert eine Anforderung in dem übergebenen Paket und Prozess in der care-packages Datenbank
 : @param $pkg-id ID des Paketes
 : @param $pkg-version Version des Paketes
 : @param $ref-id ID der Aktivität
 : @param $req-id ID der Anforderung
 : @param $template-type Variante der MASTER-Schablone (Funktional, Prozess, Umgebung, Eigenschaft)
 : @param $condition Bedingung der Anforderung als XML
 : @param $system System-Baustein der Anforderung
 : @param $liability Priorität-Baustein der Anforderung
 : @param $actor Akteur-Baustein der Anforderung
 : @param $functionality Art der Funktionalität-Baustein der Anforderung
 : @param $object-detail1 Präzisierung 1-Baustein des Objekts
 : @param $object Objekt-Baustein der Anforderung
 : @param $object-detail2 Präzisierung 2-Baustein des Objekts
 : @param $processverb-detail Konkretisierungs-Baustein des Prozesswortes
 : @param $processverb Prozesswort-Baustein
 : @param $category Kategorie der Anforderung
:)
declare updating function re:save($pkg-id,$pkg-version,$ref-id,$req-id,$template-type,$condition,$system,$liability,$actor,$functionality,$object-detail1,$object,$object-detail2,$processverb-detail,$processverb,$category,$lng) {
  let $pkg := cm:get($pkg-id,$pkg-version)
  let $packages-after := cm:packages-after($pkg)
  let $packages := $packages-after | $pkg
  let $requirement := re:new-requirement($pkg-id,$pkg-version,$ref-id,$template-type,$condition,$system,$liability,$actor,$functionality,$object-detail1,$object,$object-detail2,$processverb-detail,$processverb,$category)
  for $package in $packages
    let $existing-requirement := $package/c:Activity[@Id=$ref-id]/c:Requirements/c:Requirement[@Id=$req-id]
    return
    if($existing-requirement)
      then (if($existing-requirement/c:Condition) then replace node $existing-requirement/c:Condition with $condition else insert node $condition into $existing-requirement
           ,replace value of node $existing-requirement/c:System with $system
           ,replace value of node $existing-requirement/c:Liability with $liability
           ,replace value of node $existing-requirement/c:Actor with $actor
           ,replace value of node $existing-requirement/c:Functionality with $functionality
           ,replace value of node $existing-requirement/c:ObjectDetail1 with $object-detail1
           ,replace value of node $existing-requirement/c:Object with $object
           ,replace value of node $existing-requirement/c:ObjectDetail2 with $object-detail2
           ,replace value of node $existing-requirement/c:ProcessVerbDetail with $processverb-detail
           ,replace value of node $existing-requirement/c:ProcessVerb with $processverb)
      else insert node $requirement into $package/c:Activity[@Id=$ref-id]/c:Requirements
};