(:~ 
 : CARE dataformat management functions
 : @author   Florian Eckey, Katharina Großer
 : @version 2.0
 : @license Copyright (C) 2015-2019
 :  This program is free software: you can redistribute it and/or modify
 :  it under the terms of the GNU General Public License as published by
 :  the Free Software Foundation, version 3 of the License.
 :
 :  This program is distributed in the hope that it will be useful,
 :  but WITHOUT ANY WARRANTY; without even the implied warranty of
 :  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 :  GNU General Public License for more details.
 :
 :  You should have received a copy of the GNU General Public License
 :  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 :)
module namespace re ="masterthesis/modules/care/requirements-manager";

import module namespace cm ="masterthesis/modules/care-manager";

declare namespace c ="care";


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
  
  let $new-requirement := re:new-requirement(random:uuid(), (), $pkg-id, $pkg-version-id, $ref-id, $template-type, $condition, $system, $liability, $actor, $functionality, $object-detail1,$object,$object-detail2,$processverb-detail, $processverb, $category)
  
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
declare function re:new-requirement($id, $nr, $pkg-id, $pkg-version-id, $ref-id, $template-type, $condition, $system, $liability, $actor, $functionality,$object-detail1, $object,$object-detail2,$processverb-detail, $processverb, $category) {
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

(:~
 : Generates event triggered condition subclause
 : @param $event event object, alternative to detailed event description
 : @param $event-actor actor of event description
 : @param $event-object object of event description
 : @param $lng language the requirement is phrased in
 : @return condition clause XML
:)
declare function re:new-condition-event($event, $event-actor, $event-object, $lng) {
  
  let $conjunc := if ($lng = "de" || "DE") then "Sobald" else "As soon as"
  
  return (
    <Condition Type="event">
      <Conjunction>{$conjunc}</Conjunction>,
        {if ($event = '') then
         (
           <Subject>{$event-actor}</Subject>,
           <Verb>eintritt</Verb>,
           <Object>{$event-object}</Object>
         )
         else
         (
           <SubjectDescription>das Ereignis</SubjectDescription>,
           <Subject>{$event}</Subject>,
           <Verb>eintritt</Verb>
       )},
      </Condition>
  )
};

(:~
 : Generates logical condition subclause element
 : @param $comparison-item subject the value is defined for
 : @param $condition-comparisonOperator relational operator
 : @param $value value to compare the subject with
 : @param $logicexpression logical expression, alternative to the operator expressions
 : @param $lng language the requirement is phrased in
 : @return condition subclause (XML)
:)
declare function re:new-condition-logic($comparison-item, $condition-comparisonOperator, $value, $logicexpression, $lng) {
  
  let $conjunc := if ($lng = "de" || "DE") then "Falls" else "If"
  
  return
    <Condition Type="logic">
      <Conjunction>{$conjunc}</Conjunction>
      {if ($logicexpression = '') then
        (<ComparisonItem>{$comparison-item}</ComparisonItem>,
         <ComparisonOperator>{$condition-comparisonOperator}</ComparisonOperator>,
         <Value>{$value}</Value>,
         <Verb>ist</Verb>)
       else
         <Expression>{$logicexpression}</Expression>
      } 
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