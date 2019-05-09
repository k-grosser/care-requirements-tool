(:~
 : Activity context information panel
 : @version 1.1
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
module namespace reinfoview="masterthesis/modules/care/view/info-view";

import module namespace util="masterthesis/modules/utilities";
import module namespace gl ="masterthesis/modules/care/glossary";
import module namespace ui = 'masterthesis/modules/ui-manager';

declare namespace c="care";
declare namespace g="glossary";

(:~
: Generates the context information panel fo a given activity.
: @param $current-package current package
: @param $compare-package package current package is compared to
: @param $ref-id activity ID of selected activity
: @param $req-id requirements ID of (optionally) selected requirement
: @param $changes differences in context information compared to previous version 
: @returncontext information panel (XHTML)
:)
declare function reinfoview:info-panel($current-package, $compare-package, $ref-id, $req-id, $changes) {
  <div class="collapse-panel re-collapse-panel info-panel-header">
    <div class="header" data-toggle="collapse" aria-expanded="false" aria-controls="collapseExample">
      <dl class="palette">
        <dt><span data-i18n="[html]elicit.context"></span>{ui:info-tooltip("elicit.info")}</dt>
      </dl>
    </div>
    <div class="collapse in" id="collapseInfo">
      {reinfoview:info-div($current-package, $compare-package, $ref-id, $req-id, $changes)}
    </div>
  </div>
};

(:~
: Generates the content of the context information panel from the selected activity's data 
: @param $current-package current package
: @param $compare-package package the current package is compared to
: @param $ref-id activity ID of the selected activity
: @param $req-id requirement ID of the (optionally) selected requirement
: @param $inconsistencies inconsistencies for the selected activity
: @return context information list with inconsistencies (XHTML)
:)
declare function reinfoview:info-div($current-package, $compare-package, $ref-id, $req-id, $inconsistencies) { 
 
  let $act-info-before := $compare-package/c:Activity[@Id=$ref-id]/c:ContextInformation
  let $act-info-current := $current-package/c:Activity[@Id=$ref-id]/c:ContextInformation
  
  let $doInputs-before := $act-info-before/c:DataObjectInputs/c:DataObjectInput
  let $doInputs-current := $act-info-current/c:DataObjectInputs/c:DataObjectInput
  let $doInputs := $doInputs-current | $doInputs-before[not(@Id=$doInputs-current/@Id)]
  
  let $doOutputs-before := $act-info-before/c:DataObjectOutputs/c:DataObjectOutput
  let $doOutputs-current := $act-info-current/c:DataObjectOutputs/c:DataObjectOutput
  let $doOutputs := $doOutputs-current | $doOutputs-before[not(@Id=$doOutputs-current/@Id)]
  
  let $doCount := count($doInputs) + count($doOutputs)
  
  let $dsInputs-before := $act-info-before/c:DataStoreInputs/c:DataStoreInput
  let $dsInputs-current := $act-info-current/c:DataStoreInputs/c:DataStoreInput
  let $dsInputs := $dsInputs-current | $dsInputs-before[not(@Id=$dsInputs-current/@Id)]
  
  let $dsOutputs-before := $act-info-before/c:DataStoreOutputs/c:DataStoreOutput
  let $dsOutputs-current := $act-info-current/c:DataStoreOutputs/c:DataStoreOutput
  let $dsOutputs := $dsOutputs-current | $dsOutputs-before[not(@Id=$dsOutputs-current/@Id)]
  
  let $dsCount := count($dsInputs) + count($dsOutputs)
  
  let $predecessors-before := $act-info-before/c:Predecessors/c:Predecessor
  let $predecessors-current := $act-info-current/c:Predecessors/c:Predecessor
  let $predecessors := $predecessors-current | $predecessors-before[not(@Id=$predecessors-current/@Id)]
  
  let $predecessorCount := count($predecessors)
  
  return 
     <div id="info-div" class="panel-box info-panel">
    
       {reinfoview:info-element("elicit.name",
                                  <span style="font-weight:bold">{reinfoview:diff-name($inconsistencies, $act-info-current/c:Name)}</span>)}
       
       {reinfoview:info-element("elicit.activitytype",
                                  reinfoview:diff-taskType($inconsistencies, $act-info-current/c:TaskType))}
       
       {reinfoview:info-element("elicit.role",
                                  reinfoview:diff-perf($inconsistencies, $act-info-current/c:Performer))}
       
       {reinfoview:info-element("elicit.doc",
                                  (if ($doCount > 1) then
                                    <ol type="a"> 
                                      {for $doInput in $doInputs return <li>{reinfoview:diff-doInputs($inconsistencies, $doInput)}</li>,
                                      for $doOutput in $doOutputs return <li>{reinfoview:diff-doOutputs($inconsistencies, $doOutput)}</li>}
                                    </ol>
                                   else 
                                       for $doInput in $doInputs return reinfoview:diff-doInputs($inconsistencies, $doInput),
                                       for $doOutput in $doOutputs return reinfoview:diff-doOutputs($inconsistencies, $doOutput)
                                   ))}
                                   
       {reinfoview:info-element("elicit.sys",
                                 (if ($dsCount > 1) then
                                    <ol type="a"> 
                                      {for $dsInput in $dsInputs return <li>{reinfoview:diff-dsInputs($inconsistencies, $dsInput)}</li>,
                                       for $dsOutput in $dsOutputs return <li>{reinfoview:diff-dsOutputs($inconsistencies, $dsOutput)}</li>}
                                    </ol>
                                   else 
                                       for $dsInput in $dsInputs return reinfoview:diff-dsInputs($inconsistencies, $dsInput),
                                       for $dsOutput in $dsOutputs return reinfoview:diff-dsOutputs($inconsistencies, $dsOutput)
                                   ))}
       
       {reinfoview:info-element("elicit.pre",
                                 (if ($predecessorCount > 1) then
                                   <ol type="a"> 
                                    {for $predecessor in $predecessors return <li>{reinfoview:diff-predecessors($inconsistencies, $predecessor)}</li>}
                                   </ol>
                                  else 
                                      for $predecessor in $predecessors return reinfoview:diff-predecessors($inconsistencies, $predecessor)
                                   ))}                                 
    </div> 
};

(:~
: Generates differences visualization for the contex information panel for the activity's name
: @param $changes differences to the previous version of the activity's context information 
: @param $name activity name
: @return visialization of activity name differnces (XHTML)
:)
declare function reinfoview:diff-name($changes, $name) {
  
  let $relevant-changes := $changes[@Type=("CHANGE:ACT_NAME") and @ReferenceId=$name/@Id] 
  
  return
    switch($relevant-changes/@Operation)
      case "update" return (<span style="text-decoration: line-through;color:red">{$relevant-changes/@From/string()}</span>,
                            <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>)
                            
      case "delete" return <span style="color:red;text-decoration: line-through">{$relevant-changes/@From/string()}</span>
      
      case "insert" return <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
      
      default return <span>{reinfoview:link-html-glossary($name/string())}</span>
};

(:~
: Generates differences visualization for the contex information panel for the activity's performer (actor)
: @param $changes differences to the previous version of the activity's context information 
: @param $performer performer of activity
: @return visialization of activity performer differnces (XHTML)
:)
declare function reinfoview:diff-perf($changes, $performer) {
  
  let $relevant-changes := $changes[@Type=("CHANGE:ACT_PERF") and @ReferenceId=$performer/@Id] 
  
  return
    switch($relevant-changes/@Operation)
      case "update" return (<span style="text-decoration: line-through;color:red">{$relevant-changes/@From/string()}</span>,
                            <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>)
                            
      case "delete" return <span style="color:red;text-decoration: line-through">{$changes/@From/string()}</span>
      
      case "insert" return <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
      
      default return <span>{reinfoview:link-html-glossary($performer/string())}</span>
};

(:~
: Generates differences visualization for the contex information panel for the activity's type
: @param $changes differences to the previous version of the activity's context information 
: @param $tasktype type of activity
: @return visialization of activity type differnces (XHTML)
:)
declare function reinfoview:diff-taskType($changes, $tasktype) {
  
  let $relevant-changes := $changes[@Type=("CHANGE:ACT_TASKTYPE") and @ReferenceId=$tasktype/@Id]
  
  return
    switch($relevant-changes/@Operation)
      case "update" return (<span style="text-decoration: line-through;color:red">{$relevant-changes/@From/string()}</span>,
                            <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>)
                            
      case "delete" return <span style="color:red;text-decoration: line-through">{$relevant-changes/@From/string()}</span>
      
      case "insert" return <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
      
      default return <span>{reinfoview:link-html-glossary($tasktype/string())}</span>
};

(:~
: Generates differences visualization for the contex information panel for the activity's input data objects
: @param $changes differences to the previous version of the activity's context information 
: @param $doInput name of data object
: @return visialization of activity input data object differnces (XHTML)
:)
declare function reinfoview:diff-doInputs($changes, $doInput) {
  
  let $relevant-changes := $changes[@Type=("CHANGE:DO_INPUT_NAME","CHANGE:DO_INPUT") and @ReferenceId=$doInput/@Id]
  
  return
    switch($relevant-changes/@Operation)
      case "update" return    <span><span style="text-decoration: line-through;color:red">{$relevant-changes/@From/string()}</span>
                              <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span></span>
                            
                            
      case "delete" return <span style="color:red;text-decoration: line-through">{$relevant-changes/@From/string()}</span>
      
      case "insert" return <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
      
      default return <span>{reinfoview:link-html-glossary($doInput/string())}</span>
};

(:~
: Generates differences visualization for the contex information panel for the activity's output data objects
: @param $changes differences to the previous version of the activity's context information 
: @param $doOutput name of data object
: @return visialization of activity output data object differnces (XHTML)
:)
declare function reinfoview:diff-doOutputs($changes, $doOutput) {
  
  let $relevant-changes := $changes[@Type=("CHANGE:DO_OUTPUT_NAME","CHANGE:DO_OUTPUT") and @ReferenceId=$doOutput/@Id] 
  
  return
    switch($relevant-changes/@Operation)
      case "update" return <span>
                              <span style="text-decoration: line-through;color:red">{$relevant-changes/@From/string()}</span>
                              <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
                            </span>
                            
      case "delete" return <span style="color:red;text-decoration: line-through">{$relevant-changes/@From/string()}</span>
      
      case "insert" return <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
      
      default return <span>{reinfoview:link-html-glossary($doOutput/string())}</span>
};

(:~
: Generates differences visualization for the contex information panel for the activity's input data stores
: @param $changes differences to the previous version of the activity's context information  
: @param $dsInput name of data store
: @return visialization of activity input data store differnces (XHTML)
:)
declare function reinfoview:diff-dsInputs($changes, $dsInput) {
  let $relevant-changes := $changes[@Type=("CHANGE:DS_INPUT_NAME","CHANGE:DS_INPUT") and @ReferenceId=$dsInput/@Id]
  
  return
    switch($relevant-changes/@Operation)
      case "update" return <span>
                              <span style="text-decoration: line-through;color:red">{$relevant-changes/@From/string()}</span>
                              <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
                            </span>
                            
      case "delete" return <span style="color:red;text-decoration: line-through">{$relevant-changes/@From/string()}</span>
      
      case "insert" return <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
      
      default return <span>{reinfoview:link-html-glossary($dsInput/string())}</span>
};

(:~
: Generates differences visualization for the contex information panel for the activity's output data stores
: @param $changes differences to the previous version of the activity's context information 
: @param $dsOutput name of data store
: @return visialization of activity output data store differnces (XHTML)
:)
declare function reinfoview:diff-dsOutputs($changes, $dsOutput) {
  
  let $relevant-changes := $changes[@Type=("CHANGE:DS_OUTPUT_NAME","CHANGE:DS_OUTPUT") and @ReferenceId=$dsOutput/@Id] 
  
  return
    switch($relevant-changes/@Operation)
      case "update" return <span>
                              <span style="text-decoration: line-through;color:red">{$relevant-changes/@From/string()}</span>
                              <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
                            </span>
                            
      case "delete" return <span style="color:red;text-decoration: line-through">{$relevant-changes/@From/string()}</span>
      
      case "insert" return <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
      
      default return <span>{reinfoview:link-html-glossary($dsOutput/string())}</span>
};

(:~
: Generates differences visualization for the contex information panel for the activity's predecessors
: @param $changes differences to the previous version of the activity's context information 
: @param $predecessor name of predecessor
: @return visialization of activity predecessor differnces (XHTML)
:)
declare function reinfoview:diff-predecessors($changes, $predecessor) {
  
  let $relevant-changes := $changes[@Type=("CHANGE:ACT_PRED","CHANGE:ACT_PRED_NAME","CHANGE:ACT_PRED_TRANSITION") 
                                and @ReferenceId=$predecessor/@Id][1]
                                
  return
    switch($relevant-changes/@Operation)
      case "update" return <span>
                              <span style="color:red;text-decoration: line-through;">{$relevant-changes/@From/string()}</span>
                              <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
                            </span>
                            
      case "delete" return <span style="color:red;text-decoration: line-through">{$relevant-changes/@From/string()}</span>
      
      case "insert" return <span style="color:green">{reinfoview:link-html-glossary($relevant-changes/@To/string())}</span>
      
      default return <span>{reinfoview:link-html-glossary($predecessor/string())}</span>
};

(:~
: Generates context information element
: @param $key i18next key of the element's name
: @param $value value of the element
: @return context information element (XHTML)
:)
declare function reinfoview:info-element($key, $value) {
  let $random-id := random:uuid()
  return
    if($value and $value!="") then
      <dl class="dl-horizontal">
        <dt data-i18n="{$key}"></dt>
        <dd>{$value}</dd>
      </dl>
    else ()
};

(:~
: Searches given texts for existing glossary entries and embedes glossary entry tooltips into the text.
: @param $text text to search and markup
: @return text with embedded tooltip elements, for all detected entries (XHTML)
:)
declare function reinfoview:link-html-glossary($text) {
  for $word in tokenize($text," ") return <span>{reinfoview:link-glossary($word)}</span>
};

(:~
: Generates glossary entry tooltips with term definitions
: @param $word word to search in glossary
: @return word with embedded glossary definition tooltip or word if no entry is found (XHTML)
:)
declare function reinfoview:link-glossary($word) {
  
  let $entries := $gl:db/g:Entry[g:Key contains text {$word} using fuzzy using stemming]
  
  return
    if($entries)
      then <a title="{reinfoview:glossary2html($entries)}" data-template="{util:serialize-html(<div class='tooltip' role='tooltip'><div class='tooltip-arrow'/><div class='glossary-tooltip tooltip-inner'/></div>)}" data-toggle="tooltip" data-placement="right" data-content="{reinfoview:glossary2html($entries)}" style="cursor:help;">{$word}</a>
      else $word
};

(:~
: Generates glossary entry tooltip content
: @param $entries glossary entries
: @return content of glossary entry tooltip (XHTML)
:)
declare function reinfoview:glossary2html($entries) {
  util:serialize-html(
    for $entry in $entries
      return
        <div>
          <span style="font-weight:bold"><i>{$entry/g:Key/string()}</i> bedeutet:</span>
          <br/>
          <div>{$entry/g:Value/string()}</div>
        </div>
  )
};