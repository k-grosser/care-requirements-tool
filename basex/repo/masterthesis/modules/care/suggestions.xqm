(:~
 : Bundles Functions to calculate suggestions to fill template elements
 : @author Florian Eckey, Katharina Großer
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
module namespace rsugg ="masterthesis/modules/care/suggestions";

declare namespace c ="care";

(:~
 : Generates suggestions for the object element
 : @param $act activity
 : @return object suggestions (XML)
:)
declare function rsugg:possible-objects($act) {
  
  let $name-object := <entry Id="{random:uuid()}" Name="{tokenize($act/c:ContextInformation/c:Name/string()," ")[1]}" Type="Re ReObject ReFavorite" Icon="glyphicon glyphicon-tag"/>
  
  let $doOutputs:= $act/c:ContextInformation/c:DataObjectOutputs/c:DataObjectOutput
  let $dsOutputs :=  $act/c:ContextInformation/c:DataStoreOutputs/c:DataStoreOutput
  let $doInputs := $act/c:ContextInformation/c:DataObjectInputs/c:DataObjectInput
  let $dsInputs := $act/c:ContextInformation/c:DataStoreInputs/c:DataStoreInput 
  let $dataObjects := $doOutputs | $doInputs
  let $dataStores := $dsOutputs | $dsInputs
  
  let $doOutputEntries := for $doOutput in distinct-values($doOutputs/@Id/string()) return 
                        <entry Id="{$doOutput}" Name="{$dataObjects[@Id=$doOutput]/string()}" State="{$dataObjects[@Id=$doOutput]/@State}" Type="DataObject" Icon="glyphicon glyphicon-file"/>
  let $dsOutputEntries := for $dsOutput in distinct-values($dsOutputs/@Id/string()) return 
                        <entry Id="{$dsOutput}" Name="{$dataStores[@Id=$dsOutput]/string()}" State="{$dataStores[@Id=$dsOutput]/@State}" Type="DataStore" Icon="glyphicon glyphicon-hdd"/>
  let $doInputEntries := for $doInput in distinct-values($doInputs/@Id/string()) return 
                        <entry Id="{$doInput}" Name="{$dataObjects[@Id=$doInput]/string()}" State="{$dataObjects[@Id=$doInput]/@State}" Type="DataObject" Icon="glyphicon glyphicon-file"/>
  let $dsInputEntries := for $dsInput in distinct-values($dsInputs/@Id/string()) return 
                        <entry Id="{$dsInput}" Name="{$dataStores[@Id=$dsInput]/string()}" State="{$dataStores[@Id=$dsInput]/@State}" Type="DataStore" Icon="glyphicon glyphicon-hdd"/>
                        
  return $name-object | $doOutputEntries | $doInputEntries | $dsOutputEntries | $dsInputEntries
};

(:~
 : Generates suggestions for event elements
 : @param $act activity
 : @return event suggestions (XML)
:)
declare function rsugg:possible-events($act) {
  
  let $events := for $event in distinct-values($act/c:ContextInformation/c:Predecessors/c:Predecessor[@Type=("StartEvent"(:,"EndEvent" ... can never be explicit predecessor:),"IntermediateEvent")]/string()) return <entry Id="{random:uuid()}" Name="{$event}" Type="Re ReFavorite" Icon="glyphicon glyphicon-bell"/>
  
  return $events
};

(:~
 : Generates suggestions for compare object elemnts of conditions
 : @param $act activity
 : @return compare object suggestions (XML)
:)
declare function rsugg:possible-comparevalues($act) {
  
  let $transitions := for $actor in distinct-values($act/c:ContextInformation/c:Predecessors/c:Predecessor[@Type="ExclusiveGateway"]/@Transition/string()) return <entry Id="{random:uuid()}" Name="{$actor}" Type="Re ReActor ReFavorite" Icon="glyphicon glyphicon-random"/>
  
  return $transitions
};

(:~
 : Generates suggestions for actor elements of conditions
 : @param $care-pkg package
 : @param $act activity
 : @return condition actor suggestions (XML)
:)
declare function rsugg:possible-eventactors($care-pkg, $act) {
  let $pre := $care-pkg/c:Activity[@Id=$act/c:ContextInformation/c:Predecessors/c:Predecessor/@Id/string()]
  
  return
    if ($pre/c:ContextInformation/c:TaskType=("usertask")) then rsugg:possible-actors($pre) 
    else
      if ($pre/c:ContextInformation/c:TaskType=("servicetask")) then rsugg:possible-systems($care-pkg,$pre) 
      else 
        <entry Id="{random:uuid()}" Name="{$pre/c:ContextInformation/c:Performer/string()}" Type="Lane" Icon="glyphicon glyphicon-user"/>
        | <entry Id="{random:uuid()}" Name="{$pre/c:ContextInformation/c:Participant/string()}" Type="Lane" Icon="glyphicon glyphicon-cog"/>
};

(:~
 : Generates suggestions for object elements of conditions
 : @param $care-pkg packages
 : @param $act activity
 : @return condition object suggesstions (XML)
:)
declare function rsugg:possible-eventobjects($care-pkg, $act) {
  
  let $cadidates := for $pre in $care-pkg/c:Activity[@Id=$act/c:ContextInformation/c:Predecessors/c:Predecessor/@Id/string()]
  
  return 
    (:if event then (alles? oder erstes von Hinten?) vor letztem Leerzeichen Name="{tokenize($reference/c:ContextInformation/c:Name/string()," ")[last()]}" else:)
    if($pre/@Type=("StartEvent"(:,"EndEvent" ... can never be explicit predecessor:),"IntermediateEvent")) then 
      <entry Id="{random:uuid()}" Name="{tokenize($pre/c:ContextInformation/c:Name/string()," ")[last()-1]}" Type="Re ReObject ReFavorite" Icon="glyphicon glyphicon-tag"/> else rsugg:possible-objects($pre)
  
  return $cadidates
};

(:~
 : Generates suggestions for function elements of conditions
 : @param $care-pkg package
 : @param $act activity
 : @return condition function suggestions (XML)
:)
declare function rsugg:possible-functions($care-pkg, $act) {
  
  let $cadidates := for $pre in $care-pkg/c:Activity[@Id=$act/c:ContextInformation/c:Predecessors/c:Predecessor/@Id/string()]
  
  return 
    if($pre/@Type=("ExclusiveGateway","InclusiveGateway","ParallelGateway")) then ()
    else
      <entry Id="{random:uuid()}" Name="{$pre/c:ContextInformation/c:Name/string()}" Type="Re ReObject ReFavorite" Icon="glyphicon glyphicon-tag"/>
      return $cadidates
};

(:~
 : Generates suggestions for process verb elements of conditions
 : @param $care-pkg package
 : @param $act activity
 : @return condition process verb suggestions (XML)
:)
declare function rsugg:possible-condition-processverbs($care-pkg, $act) {
  
  let $cadidates := for $pre in $care-pkg/c:Activity[@Id=$act/c:ContextInformation/c:Predecessors/c:Predecessor/@Id/string()]
  
  return 
    if($pre/@Type=("ExclusiveGateway","InclusiveGateway","ParallelGateway")) then ()
    else
      rsugg:possible-processverbs($care-pkg, $pre)
      return $cadidates
};

(:~
 : Generates suggestions for actor elements
 : @param $act activity
 : @return actor element suggestions (XML)
:)
declare function rsugg:possible-actors($act) {
  
  let $emptyEntry := <entry Id="{random:uuid()}" Name="" Type="Lane" Icon="glyphicon glyphicon-remove"/>
  let $laneEntry := <entry Id="{random:uuid()}" Name="{$act/c:ContextInformation/c:Performer/string()}" Type="Lane" Icon="glyphicon glyphicon-user"/>
  
  return if ($act/c:ContextInformation/c:TaskType=("usertask")) then $laneEntry else $emptyEntry | $laneEntry
};

(:~
 : Generates suggestions for system elements
 : @param $care-pkg package
 : @param $reference activity
 : @return system element suggestions (XML)
:)
declare function rsugg:possible-systems($care-pkg, $reference) {
   if ($reference/c:ContextInformation/c:TaskType=("servicetask")) then
    let $laneEntry := <entry Id="{random:uuid()}" Name="{$reference/c:ContextInformation/c:Performer/string()}" Type="Lane" Icon="glyphicon glyphicon-user"/>
    let $pool-system := <entry Id="{random:uuid()}" Name="{$reference/c:ContextInformation/c:Participant/string()}" Type="Pool" Icon="glyphicon glyphicon-cog"/>
    let $other-systems := for $system in distinct-values($care-pkg//c:System) return <entry Id="{random:uuid()}" Name="{$system}" Type="Re ReSystem ReFavorite" Icon="glyphicon glyphicon-star"/>
    
    return  $laneEntry | $pool-system | $other-systems
  else
    let $pool-system := <entry Id="{random:uuid()}" Name="{$reference/c:ContextInformation/c:Participant/string()}" Type="Lane" Icon="glyphicon glyphicon-cog"/>
    let $other-systems := for $system in distinct-values($care-pkg//c:System) return <entry Id="{random:uuid()}" Name="{$system}" Type="Re ReSystem ReFavorite" Icon="glyphicon glyphicon-star"/>
    
    return $pool-system | $other-systems
};

(:~
 : Generates suggestions for compare item elements
 : @param $act activity
 : @return compare item suggestions (XML)
:)
declare function rsugg:possible-compareItems($act) {
  
  let $items := for $value in distinct-values($act/c:ContextInformation/c:Predecessors/c:Predecessor[@Type="ExclusiveGateway"]/string()) return <entry Id="{random:uuid()}" Name="{$value}" Type="Re ReActor ReFavorite" Icon="glyphicon glyphicon-hand-right"/>
  
  return $items
};

(:~
 : Generates suggestions for logical expressions
 : @param $act activity
 : @return logical expression suggestions (XML)
:)
declare function rsugg:possible-logicexpressions($act) {
  
  let $gateways := for $value in distinct-values($act/c:ContextInformation/c:Predecessors/c:Predecessor[@Type="ExclusiveGateway"]/string()) return <entry Id="{random:uuid()}" Name="{$value}" Type="Re ReActor ReFavorite" Icon="glyphicon glyphicon-hand-right"/>
  
  return $gateways
};

(:~
 : Generates suggestions for legal liabilities
 : @return legal liability (modal verb) suggestions (XML)
:)
declare function rsugg:possible-liabilities() {
  
  let $master-liabilities := (<entry Id="{random:uuid()}" Name="muss" Type="Re ReLiability"/>
                            ,<entry Id="{random:uuid()}" Name="kann" Type="Re ReLiability"/>
                            ,<entry Id="{random:uuid()}" Name="soll" Type="Re ReLiability"/>)
                            
  return $master-liabilities
};

(:~
 : Generates suggestions for realtional operators
 : @return relational operator suggestions (XML)
:)
declare function rsugg:possible-operators($care-ref) {
  
  let $operators := (<entry Id="{random:uuid()}" Name="gleich" Type="Re"/>
                            ,<entry Id="{random:uuid()}" Name="kleiner" Type="Re"/>
                            ,<entry Id="{random:uuid()}" Name="größer" Type="Re"/>)
                            
  return $operators
};


(:~
 : Generates suggestions for system activity type phrases
 : @param $act activity
 : @return system activity type phrase suggestions (XML)
:)
declare function rsugg:possible-functionalities($act) {
  
  let $other-functionalities := 
  
     if ($act/c:ContextInformation/c:TaskType=("servicetask") or $act/c:ContextInformation/c:TaskType=("sendtask")) then
  
  (<entry Id="{random:uuid()}" Name="" Type="Re ReFunctionality" Icon="glyphicon glyphicon-cog"/>,
 <entry Id="{random:uuid()}" Name="die Möglichkeit bieten" Type="Re ReFunctionality" Icon="glyphicon glyphicon-user"/>
                            ,<entry Id="{random:uuid()}" Name="fähig sein" Type="Re ReFunctionality" Icon="glyphicon glyphicon-link"/>)
                            
     else if ($act/c:ContextInformation/c:TaskType=("usertask")) then
  
   (<entry Id="{random:uuid()}" Name="die Möglichkeit bieten" Type="Re ReFunctionality" Icon="glyphicon glyphicon-user"/>
                            ,<entry Id="{random:uuid()}" Name="fähig sein" Type="Re ReFunctionality" Icon="glyphicon glyphicon-link"/>
                            ,<entry Id="{random:uuid()}" Name="" Type="Re ReFunctionality" Icon="glyphicon glyphicon-cog"/>)
                            
     else if ($act/c:ContextInformation/c:TaskType=("scripttask") or $act/c:ContextInformation/c:TaskType=("businessruletask") or $act/c:ContextInformation/c:TaskType=("receivetask")) then
  
   (<entry Id="{random:uuid()}" Name="fähig sein" Type="Re ReFunctionality" Icon="glyphicon glyphicon-link"/>
                            ,<entry Id="{random:uuid()}" Name="die Möglichkeit bieten" Type="Re ReFunctionality" Icon="glyphicon glyphicon-user"/>
                            ,<entry Id="{random:uuid()}" Name="" Type="Re ReFunctionality" Icon="glyphicon glyphicon-cog"/>)
                            
     else if ($act/c:ContextInformation/c:TaskType=("manualtask")) then
  
   (<entry Id="{random:uuid()}" Name="" Type="Re ReFunctionality" Icon="glyphicon glyphicon-user"/>,
   <entry Id="{random:uuid()}" Name="fähig sein" Type="Re ReFunctionality" Icon="glyphicon glyphicon-link"/>
                            ,<entry Id="{random:uuid()}" Name="die Möglichkeit bieten" Type="Re ReFunctionality" Icon="glyphicon glyphicon-user"/>
                            ,<entry Id="{random:uuid()}" Name="" Type="Re ReFunctionality" Icon="glyphicon glyphicon-cog"/>)
                            
     else
  
  (<entry Id="{random:uuid()}" Name="" Type="Re ReFunctionality" Icon="glyphicon glyphicon-cog"/>,
  <entry Id="{random:uuid()}" Name="die Möglichkeit bieten" Type="Re ReFunctionality" Icon="glyphicon glyphicon-user"/>
                            ,<entry Id="{random:uuid()}" Name="fähig sein" Type="Re ReFunctionality" Icon="glyphicon glyphicon-link"/>,
                          <entry Id="{random:uuid()}" Name="" Type="Re ReFunctionality" Icon="glyphicon glyphicon-user"/>)
                            
  return $other-functionalities
};

(:~
 : Generates suggestions for process verbs
 : @param $care-pkg package
 : @param $reference activity
 : @return process verb suggesstions (XML)
:)
declare function rsugg:possible-processverbs($care-pkg, $reference) {
  
   let $name-object := <entry Id="{random:uuid()}" Name="{tokenize($reference/c:ContextInformation/c:Name/string()," ")[last()]}" Type="Re ReObject ReFavorite" Icon="glyphicon glyphicon-tag"/>
  
  let $other-processverbs := for $processverbs in distinct-values($care-pkg//c:ProcessVerb/string()) return <entry Id="{random:uuid()}" Name="{$processverbs}" Type="Re ReProcessVerb ReFavorite" Icon="glyphicon glyphicon-star"/>
  
  return $name-object | $other-processverbs
};

(:~
 : Generates suggestions for process verb details
 : @param $care-pkg package
 : @param $reference activity
 : @return process verb detail suggestions (XML)
:)
declare function rsugg:possible-processverbdetails($care-pkg, $reference) {
  
  let $other-processverbdetails := for $processverbdetail in distinct-values($care-pkg//c:ProcessVerbDetail/string()) return <entry Id="{random:uuid()}" Name="{$processverbdetail}" Type="Re ReProcessVerbDetail ReFavorite" Icon="glyphicon glyphicon-star"/>
  
  return $other-processverbdetails
};

(:~
 : Generates suggestions for object states
 : @param $act activity
 : @return object state suggestions (XML)
:)
declare function rsugg:possible-states($act) {
  
  let $states := for $object in rsugg:possible-objects($act)[@State!=""] return <entry Id="{random:uuid()}" Name="{$object/@State}" Type="Re ReObjectDetail1 ReFavorite" Icon="glyphicon glyphicon-file"/>
    
  return $states
};

(:~
 : Generates suggestions for objects of state dependend time-span conditions
 : @param $care-pkg package
 : @param $act activity
 : @return object suggestions (XML)
:)
declare function rsugg:possible-stateobjects($care-pkg, $act) {
  let $objects := rsugg:possible-objects($act)
  let $systems := rsugg:possible-systems($care-pkg, $act)
    
  return $objects | $systems
};

(:~
 : Generates suggestions for the prefix object details
 : @param $care-pkg package
 : @param $reference activity
 : @return object prefix suggestions (XML)
:)
declare function rsugg:possible-objectdetails1($care-pkg,$reference) {
  let $state-objectdetails1 := rsugg:possible-states($reference)
  let $other-objectdetails1 := for $objectdetail1 in distinct-values($care-pkg//c:ObjectDetail1/string()) return <entry Id="{random:uuid()}" Name="{$objectdetail1}" Type="Re ReObjectDetail1 ReFavorite" Icon="glyphicon glyphicon-star"/>
  
  return $state-objectdetails1 | $other-objectdetails1
};

(:~
 : Generates suggestions for the postfix object details
 : @param $care-pkg package
 : @param $reference activity
 : @return object postfix suggestions (XML)
:)
declare function rsugg:possible-objectdetails2($care-pkg,$reference) {
  let $other-objectdetails2 := for $objectdetail2 in distinct-values($care-pkg//c:ObjectDetail2/string()) return <entry Id="{random:uuid()}" Name="{$objectdetail2}" Type="Re ReObjectDetail2 ReFavorite" Icon="glyphicon glyphicon-star"/>
  return $other-objectdetails2
};