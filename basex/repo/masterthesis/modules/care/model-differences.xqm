(:~
 : Detection of differences in activity context information
 : @version 2.0
 : @author Florian Eckey, Katharina Großer
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
module namespace diff="masterthesis/modules/care/model-differences";

declare namespace c ="care";

(:~
 : Detects differences for packages, delegates to difference detection for contained activities
 : @param $pkg1 package (old)
 : @param $pkg2 package to compare with (new)
 : @return differences between packages (XHTML)
:)
declare function diff:Activities($pkg1, $pkg2) {
  
  let $acts1 := $pkg1/c:Activity/c:ContextInformation
  let $acts2 := $pkg2/c:Activity/c:ContextInformation
  
  return (
    for $act1 in $acts1 where not($act1/@Id/string() = ($acts2/@Id/string())) 
    return <Inconsistency Operation="delete" Type="CHANGE:ACT" ReferenceId="{$act1/@ActivityId}" PackageId="{$pkg1/@Id}"><span><span data-i18n="diff.act"></span><span class="change-from">{$act1/c:Name/string()}</span><span data-i18n="diff.del"></span></span></Inconsistency>, 
    
    for $act2 in $acts2 where not($act2/@Id/string() = ($acts1/@Id/string())) return <Inconsistency Operation="insert" Type="CHANGE:ACT"  ReferenceId="{$act2/@ActivityId}" PackageId="{$pkg1/@Id}"><span><span data-i18n="diff.act"></span><span class="change-to">{$act2/c:Name/string()}</span><span data-i18n="diff.act"></span><span data-i18n="diff.elicit"></span></span></Inconsistency>,
    
    for $act1 in $acts1,$act2 in $acts2 where $act1/@Id=$act2/@Id 
    return diff:Activity($act1, $act2))
};

(:~
 : Detects differences in context information for activities
 : @param $act1 activity (old)
 : @param $act2 activity to compare (new)
 : @return differences between activities (XHTML)
:)
declare function diff:Activity($act1, $act2) {
  
  if($act1/c:Name/string() = $act2/c:Name/string()) then () 
  else <Inconsistency Operation="update" From="{$act1/c:Name/string()}" To="{$act2/c:Name/string()}" Type="CHANGE:ACT_NAME" ReferenceId="{$act1/c:Name/@Id}"><span><span data-i18n="diff.actname"></span><span data-i18n="diff.changefrom"></span><span class="change-from">{$act1/c:Name/string()}</span><span data-i18n="diff.to"></span><span class="change-to">{$act2/c:Name/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>,
  
  if($act1/c:Performer/string() = $act2/c:Performer/string()) then () 
  else <Inconsistency Operation="update" From="{$act1/c:Performer/string()}" To="{$act2/c:Performer/string()}" Type="CHANGE:ACT_PERF" ReferenceId="{$act1/c:Performer/@Id}"><span><span data-i18n="diff.resp"></span><span data-i18n="diff.changefrom"></span><span class="change-from">{$act1/c:Performer/string()}</span><span data-i18n="diff.to"></span><span class="change-to">{$act2/c:Performer/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>,
  
  if($act1/c:Participant/string() = $act2/c:Participant/string()) then () 
  else <Inconsistency Operation="update" From="{$act1/c:Participant/string()}" To="{$act2/c:Participant/string()}" Type="CHANGE:ACT_PART" ReferenceId="{$act1/c:Participant/@Id}"><span><span data-i18n="diff.perf"></span><span data-i18n="diff.changefrom"></span><span class="change-from">{$act1/c:Participant/string()}</span><span data-i18n="diff.to"></span><span class="change-to">{$act2/c:Participant/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>,
  
  if($act1/c:TaskType/string() = $act2/c:TaskType/string()) then () 
  else <Inconsistency Operation="update" From="{$act1/c:TaskType/string()}" To="{$act2/c:TaskType/string()}" Type="CHANGE:ACT_TASKTYPE" ReferenceId="{$act1/c:TaskType/@Id}"><span><span data-i18n="diff.acttype"></span><span data-i18n="diff.changefrom"></span><span class="change-from">{$act1/c:TaskType/string()}</span><span data-i18n="diff.to"></span><span class="change-to">{$act2/c:TaskType/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>,
  
  diff:DataObjectInputs($act1, $act2),
  diff:DataObjectOutputs($act1, $act2),
  diff:DataStoreInputs($act1, $act2),
  diff:DataStoreOutputs($act1, $act2),
  diff:Predecessors($act1, $act2)
};

(:~
 : Detects differences in data object inputs of activities
 : @param $act1 activity (old)
 : @param $act2 activity to compare with (new)
 : @return differences of data object inputs (XHTML)
:)
declare function diff:DataObjectInputs($act1, $act2) {
  
  let $doInputs1 := $act1/c:DataObjectInputs/c:DataObjectInput
  let $doInputs2 := $act2/c:DataObjectInputs/c:DataObjectInput
  
  return (
    for $doInput1 in $doInputs1 where not($doInput1/@Id/string() = ($doInputs2/@Id/string())) 
    return <Inconsistency Operation="delete" Type="CHANGE:DO_INPUT" From="{$doInput1/string()}" ReferenceId="{$doInput1/@Id}"><span><span data-i18n="diff.doc"></span><span class="change-from">{$doInput1/string()}</span><span data-i18n="diff.del"></span></span></Inconsistency>,
      
    for $doInput2 in $doInputs2 where not($doInput2/@Id/string()=($doInputs1/@Id/string())) return <Inconsistency Operation="insert" Type="CHANGE:DO_INPUT" To="{$doInput2/string()}" ReferenceId="{$doInput2/@Id}"><span><span data-i18n="diff.doc"></span><span class="change-to">{$doInput2/string()}</span><span data-i18n="diff.add"></span></span></Inconsistency>,
     
    for $doInput1 in $doInputs1,$doInput2 in $doInputs2 where ($doInput1/@Id = $doInput2/@Id) and not(diff:hash-eq($doInput1, $doInput2)) 
    return diff:DataObjectInput($doInput1, $doInput2)
  )
};

(:~
 : Detects differences in data object outputs of activities
 : @param $act1 activity (old)
 : @param $act2 activity to compare with (new)
 : @return differences of data object outputs (XHTML)
:)
declare function diff:DataObjectOutputs($act1, $act2) {
  
  let $doOutputs1 := $act1/c:DataObjectOutputs/c:DataObjectOutput
  let $doOutputs2 := $act2/c:DataObjectOutputs/c:DataObjectOutput
  
  return (
    for $doOutput1 in $doOutputs1 where not($doOutput1/@Id/string() = ($doOutputs2/@Id/string())) 
    return <Inconsistency Operation="delete" Type="CHANGE:DO_OUTPUT" From="{$doOutput1/string()}" ReferenceId="{$doOutput1/@Id}"><span><span data-i18n="diff.doc"></span><span class="change-from">{$doOutput1/string()}</span><span data-i18n="diff.del"></span></span></Inconsistency>,
     
    for $doOutput2 in $doOutputs2 where not($doOutput2/@Id/string()=($doOutputs1/@Id/string())) return <Inconsistency Operation="insert" Type="CHANGE:DO_OUTPUT" To="{$doOutput2/string()}" ReferenceId="{$doOutput2/@Id}"><span><span data-i18n="diff.doc"></span><span class="change-to">{$doOutput2/string()}</span><span data-i18n="diff.add"></span></span></Inconsistency>,
     
    for $doOutput1 in $doOutputs1, $doOutput2 in $doOutputs2 where ($doOutput1/@Id = $doOutput2/@Id) and not(diff:hash-eq($doOutput1, $doOutput2)) 
    return diff:DataObjectOutput($doOutput1, $doOutput2)
  )
};

(:~
 : Detects differences in data store inputs of activities
 : @param $act1 activity (old)
 : @param $act2 activity to compare with (new)
 : @return differences of data store inputs (XHTML)
:)
declare function diff:DataStoreInputs($act1, $act2) {
  
  let $dsInputs1 := $act1/c:DataStoreInputs/c:DataStoreInput
  let $dsInputs2 := $act2/c:DataStoreInputs/c:DataStoreInput
  
  return (
    for $dsInput1 in $dsInputs1 where not($dsInput1/@Id/string() = ($dsInputs2/@Id/string())) 
    return <Inconsistency Operation="delete" Type="CHANGE:DS_INPUT" From="{$dsInput1/string()}" ReferenceId="{$dsInput1/@Id}"><span><span data-i18n="diff.ds"></span><span class="change-from">{$dsInput1/string()}</span><span data-i18n="diff.del"></span></span></Inconsistency>,
      
    for $dsInput2 in $dsInputs2 where not($dsInput2/@Id/string() = ($dsInputs1/@Id/string())) 
    return <Inconsistency Operation="insert" Type="CHANGE:DS_INPUT" To="{$dsInput2/string()}" ReferenceId="{$dsInput2/@Id}"><span><span data-i18n="diff.ds"></span><span class="change-to">{$dsInput2/string()}</span><span data-i18n="diff.add"></span></span></Inconsistency>,
     
    for $dsInput1 in $dsInputs1, $dsInput2 in $dsInputs2 where ($dsInput1/@Id = $dsInput2/@Id) and not(diff:hash-eq($dsInput1, $dsInput2)) 
    return diff:DataStoreInput($dsInput1, $dsInput2)
  )
};

(:~
 : Detects differences in data store outputs of activities
 : @param $act1 activity (old)
 : @param $act2 activity to compare with (new)
 : @return differences of data store outputs (XHTML)
:)
declare function diff:DataStoreOutputs($act1, $act2) {
  
  let $dsOutputs1 := $act1/c:DataStoreOutputs/c:DataStoreOutput
  let $dsOutputs2 := $act2/c:DataStoreOutputs/c:DataStoreOutput
  
  return (
    for $dsOutput1 in $dsOutputs1 where not($dsOutput1/@Id/string() = ($dsOutputs2/@Id/string())) 
    return <Inconsistency Operation="delete" Type="CHANGE:DS_OUTPUT" From="{$dsOutput1/string()}" ReferenceId="{$dsOutput1/@Id}"><span><span data-i18n="diff.ds"></span><span class="change-from">{$dsOutput1/string()}</span><span data-i18n="diff.del"></span></span></Inconsistency>,
     
    for $dsOutput2 in $dsOutputs2 where not($dsOutput2/@Id/string() = ($dsOutputs1/@Id/string())) 
    return <Inconsistency Operation="insert" Type="CHANGE:DS_OUTPUT" To="{$dsOutput2/string()}" ReferenceId="{$dsOutput2/@Id}"><span><span data-i18n="diff.ds"></span><span class="change-to">{$dsOutput2/string()}</span><span data-i18n="diff.add"></span></span></Inconsistency>,
     
    for $dsOutput1 in $dsOutputs1, $dsOutput2 in $dsOutputs2 where ($dsOutput1/@Id = $dsOutput2/@Id) and not(diff:hash-eq($dsOutput1, $dsOutput2)) 
    return diff:DataStoreOutput($dsOutput1, $dsOutput2)
  )
};

(:~
 : Detects differences in predecessors of activities
 : @param $act1 activity (old)
 : @param $act2 activity to compare with (new)
 : @return differences of predecessors (XHTML)
:)
declare function diff:Predecessors($act1, $act2) {
  
  let $predecessors1 := $act1/c:Predecessors/c:Predecessor
  let $predecessors2 := $act2/c:Predecessors/c:Predecessor
  
  return (
    for $predecessor1 in $predecessors1 where not($predecessor1/@Id/string() = ($predecessors2/@Id/string())) 
    return <Inconsistency Operation="delete" Type="CHANGE:ACT_PRED" From="{$predecessor1/string()}" ReferenceId="{$predecessor1/@Id}"><span><span data-i18n="diff.pre"></span><span class="change-from">{$predecessor1/string()}</span><span data-i18n="diff.del"></span></span></Inconsistency>,
      
    for $predecessor2 in $predecessors2 where not($predecessor2/@Id/string() = ($predecessors1/@Id/string())) 
    return <Inconsistency Operation="insert" Type="CHANGE:ACT_PRED" To="{$predecessor2/string()}" ReferenceId="{$predecessor2/@Id}"><span><span data-i18n="diff.pre"></span><span class="change-to">{$predecessor2/string()}</span><span data-i18n="diff.add"></span></span></Inconsistency>,
      
    for $predecessor1 in $predecessors1, $predecessor2 in $predecessors2 where ($predecessor1/@Id = $predecessor2/@Id) and not(diff:hash-eq($predecessor1, $predecessor2)) 
    return diff:Predecessor($predecessor1, $predecessor2)
  )
};

(:~
 : Detects differences in input data objects
 : @param $do1 data object (old)
 : @param $do2 data object to compare with (new)
 : @return differences of data objects (XHTML)
:)
declare function diff:DataObjectInput($do1, $do2) {
  if($do1/string() = $do2/string()) then () 
  else <Inconsistency Operation="update" From="{$do1/string()}" To="{$do2/string()}" Type="CHANGE:DO_INPUT_NAME" ReferenceId="{$do1/@Id}"><span><span data-i18n="diff.doc"></span><span class="change-from">{$do1/string()}</span><span data-i18n="diff.changeinto"></span><span class="change-to">{$do2/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>,
  
  diff:DataObjectState($do1, $do2)
};

(:~
 : Detects differences in output data objects
 : @param $do1 data object (old)
 : @param $do2 data object to compare with (new)
 : @return differences of data objects (XHTML)
:)
declare function diff:DataObjectOutput($do1, $do2) {
  if($do1/string() = $do2/string()) then () 
  else <Inconsistency Operation="update" From="{$do1/string()}" To="{$do2/string()}" Type="CHANGE:DO_OUTPUT_NAME" ReferenceId="{$do1/@Id}"><span><span data-i18n="diff.doc"></span><span class="change-from">{$do1/string()}</span><span data-i18n="diff.changeinto"></span><span class="change-to">{$do2/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>,
  
  diff:DataObjectState($do1, $do2)
};

(:~
 : Detects differences of data object states
 : @param $do1 data object (old)
 : @param $do2 compare data object (new)
 : @return Differences of data object states (XHTML)
:)
declare function diff:DataObjectState($do1, $do2) { 
  if($do1/@State=$do2/@State) then () 
  else if ($do1/@State="") then <Inconsistency Operation="insert" To="{$do2/@State}" Type="CHANGE:DO_STATE" ReferenceId="{$do2/@Id}"><span><span data-i18n="diff.docstate"></span><span class="change-to">[{$do2/@State}]</span><span data-i18n="diff.add"></span></span></Inconsistency>
  
  else if ($do2/@State="") then <Inconsistency Operation="delete" From="{$do1/@State}" Type="CHANGE:DO_STATE" ReferenceId="{$do1/@Id}"><span><span data-i18n="diff.docstate"></span><span class="change-to">[{$do1/@State}]</span><span data-i18n="diff.del"></span></span></Inconsistency>
  
  else <Inconsistency Operation="update" From="{$do1/@State}" To="{$do2/@State}" Type="CHANGE:DO_STATE" ReferenceId="{$do1/@Id}"><span><span data-i18n="diff.docstate"></span><span class="change-from">[{$do1/@State}]</span><span data-i18n="diff.changeinto"></span><span class="change-to">[{$do2/@State}]</span><span data-i18n="diff.changeto"></span></span></Inconsistency>
};

(:~
 : Detects differences of input data stores
 : @param $ds1 data store (old)
 : @param $ds2 data store to compare with (new)
 : @return Differences of data stores (XHTML)
:)
declare function diff:DataStoreInput($ds1, $ds2) {
  if($ds1/string() = $ds2/string()) then () 
  else <Inconsistency Operation="update" From="{$ds1/string()}" To="{$ds2/string()}" Type="CHANGE:DS_INPUT_NAME" ReferenceId="{$ds1/@Id}"><span><span data-i18n="diff.ds"></span><span class="change-from">{$ds1/string()}</span><span data-i18n="diff.changeinto"></span><span class="change-to">{$ds2/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>
};

(:~
 : Detects differences of output data stores
 : @param $ds1 data store (old)
 : @param $ds2 data store to compare with (new)
 : @return Differences of data stores (XHTML)
:)
declare function diff:DataStoreOutput($ds1, $ds2) {
  if($ds1/string() = $ds2/string()) then () 
  else <Inconsistency Operation="update" From="{$ds1/string()}" To="{$ds2/string()}" Type="CHANGE:DS_OUTPUT_NAME" ReferenceId="{$ds1/@Id}"><span><span data-i18n="diff.ds"></span><span class="change-from">{$ds1/string()}</span><span data-i18n="diff.changeinto"></span><span class="change-to">{$ds2/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>
};

(:~
 : Detects differences of predecessors
 : @param $pre1 predecessor (old)
 : @param $pre2 predecessor to compare with (new)
 : @return Differences of predecessors (XHTML)
:)
declare function diff:Predecessor($pre1, $pre2) {
  if($pre1/string() = $pre2/string()) then () 
  else <Inconsistency Operation="update" From="{$pre1/string()}" To="{$pre2/string()}" Type="CHANGE:ACT_PRED_NAME" ReferenceId="{$pre1/@Id}"><span><span data-i18n="diff.prename"></span><span class="change-from">{$pre1/string()}</span><span data-i18n="diff.changeinto"></span><span class="change-to">{$pre2/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>,
  
  if($pre1/@Type/string()=$pre2/@Type/string()) then () 
  else <Inconsistency Operation="update" Type="CHANGE:ACT_PRED_TYPE" From="{$pre1/@Type/string()}" To="{$pre2/@Type/string()}" ReferenceId="{$pre1/@Id}"><span><span data-i18n="diff.pretype"></span><span class="change-from">{$pre1/string()}</span><span data-i18n="diff.changefrom"></span>{$pre1/@Type/string()}<span data-i18n="diff.to"></span><span class="change-to">{$pre2/@Type/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>,
  
  if($pre1/@Transition/string()=$pre2/@Transition/string()) then () 
  else <Inconsistency Operation="update" Type="CHANGE:ACT_PRED_TRANSITION" From="{$pre1/@Transition/string()}" To="{$pre2/@Transition/string()}" ReferenceId="{$pre1/@Id}"><span><span data-i18n="diff.pretrans"></span>{$pre1/string()}<span data-i18n="diff.changefrom"></span><span class="change-from">{$pre1/@Transition/string()}</span><span data-i18n="diff.to"></span><span class="change-to">{$pre2/@Transition/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>,
  
  if($pre1/@Performer/string() = $pre2/@Performer/string()) then () 
  else <Inconsistency Operation="update" Type="CHANGE:ACT_PRED_PERFORMER" From="{$pre1/@Performer/string()}" To="{$pre2/@Performer/string()}" ReferenceId="{$pre1/@Id}"><span><span data-i18n="diff.preresp"></span><span class="change-from">{$pre1/string()}</span><span data-i18n="diff.changefrom"></span>{$pre1/@Performer/string()}<span data-i18n="diff.to"></span><span class="change-to">{$pre2/@Performer/string()}</span><span data-i18n="diff.changeto"></span></span></Inconsistency>
};

(:~
 : Checks equality of two XML elements
 : @param $e1 XML element
 : @param $e2 XML element to compare with
 : @return true if md5 hash of e1 equals e2, else false 
:)
declare function diff:hash-eq($e1, $e2) {
  if(hash:md5(serialize($e1)) = hash:md5(serialize($e2))) then xs:boolean("true") else xs:boolean("false")
};