(:~
 : Requirements list panel. Lists all requirements that belong to a selected activity
 : @version 1.1
 : @author Florian Eckey
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
module namespace view="masterthesis/modules/care/view/list-view";

import module namespace util = "masterthesis/modules/utilities";
import module namespace ui = 'masterthesis/modules/ui-manager';

declare namespace c="care";

(:~
 : Generates requirements list panel. Lists all requirements that belong to a selected activity
 : @param $package package the requirements belong to
 : @param $compare-package package inconsistencies of the requirements are calculated towards
 : @param $ref-id activity ID of the activity the requirements belong to
 : @param $req-id requirement ID of the (optionally) selected requirement
 : @param $inconsistencies calculated inconsistencies
 : @param $lng active GUI language
 : @return requirements list panel (XHTML)
 :)
declare function view:list-panel($package, $compare-package, $ref-id, $req-id, $inconsistencies, $lng) {
  <div class="collapse-panel re-collapse-panel">
    <div class="header" data-toggle="collapse" aria-expanded="false" aria-controls="collapseExample">
      <dl class="palette">
        <dt><span data-i18n="processlist.reqlist"></span>{ui:info-tooltip("elicit.reqlisttt")}</dt>
      </dl>
    </div>
    <div class="collapse in" id="collapseList">
      {view:view-elements($package, $compare-package, $ref-id, $req-id, $inconsistencies, $lng)}
    </div>
  </div>
};

(:~
 : Generates requirements table with action buttons to delete or edit 
 : @param $package current package
 : @param $compare-package package to compare with (old)
 : @param $ref-id activity ID of selected activity
 : @param $selected-req-id requirement ID of (optionally) selected requirement
 : @param $inconsistencies inconsistencies of current activity towards older version
 : @param $lng active GUI language
 : @return table with requirements (XHTML)
:)
declare function view:view-elements($package, $compare-package, $ref-id, $selected-req-id, $inconsistencies, $lng) {
  
  let $current-requirements := $package/c:Activity[@Id=$ref-id]/c:Requirements/c:Requirement
  let $requirements := $current-requirements 
  
  return
    <div  class="panel-box" style="">
      {if(count($requirements) > 0) then <table class="table noindent">
        <tbody>
        {for $requirement in $requirements order by $requirement/@Timestamp descending return view:requirements-list-item($package, $compare-package, $ref-id, $requirement/@Id, $selected-req-id, $inconsistencies, $lng)}
         </tbody>
        </table> 
       else 
        <div class="text-center"><b data-i18n="reqlist.noreqs"></b></div>}
    </div>
};

(:~
 : Generates a table entry for a requirement 
 : @param $current-package current package
 : @param $compare-package package to compare with (old)
 : @param $ref-id activity ID of selected activity
 : @param $selected-req-id requirement ID of (optionally) selected requirement
 : @param $req-id requirement ID of requirement the entry is generated for
 : @param $inconsistencies inconsistencies of current activity towards older version
 : @param $lng active GUI language
 : @return table row for requirement entry (XHTML)
:)
declare function view:requirements-list-item($current-package, $compare-package, $ref-id, $req-id, $selected-req-id, $inconsistencies, $lng) {  
 
  let $requirement := $current-package/c:Activity[@Id=$ref-id]/c:Requirements/c:Requirement[@Id=$req-id]
  
  return
    if($requirement) then
      <tr id="list-item{$requirement/@Id}" class="re-row {if($requirement/@Id=$selected-req-id) then 'list-active' else ()}">
        <td>{$requirement/@Prefix/string()}</td>
        {view:requirement-tr($requirement, $inconsistencies)}
        <td style="width:2%"><a class="glyphicon glyphicon-pencil re-edit" style="cursor:pointer" href="{$ui:prefix}/requirements-manager/assist/{$current-package/@Id}/{$current-package/@VersionId}/{$ref-id}/{$lng}?req-id={$requirement/@Id}" data-i18n="[title]reqlist.edit"/></td>
        <td style="width:2%"><a class="glyphicon glyphicon-remove re-remove" href="{$ui:prefix}/relist/delete/{$current-package/@Id}/{$current-package/@VersionId}/{$ref-id}/{$requirement/@Id}/{$lng}" data-i18n="[title]reqlist.del"/></td>
      </tr> 
    else ()
};

(:~
 : Creates bootstrap tooltip to show inconsistencies for given template element 
 : @param $inconsistencies differences to previous version calculated for the current activity
 : @param $types types of changes the element should be checked for
 : @param $tmp templates element to check and annotate
 : @return $tmp template element with embedded tooltip (XHTML) 
:)
declare function view:validation-tooltip($inconsistencies, $types, $tmp) {
  
  let $relevant-changes := $inconsistencies[@Type=$types]
  
  return
    if($relevant-changes and $relevant-changes/@From/string()=$tmp) then
    <span style="cursor:help;color:orange" data-toggle="tooltip" data-template="{util:serialize-html(<div class='tooltip' role='tooltip'><div class='tooltip-arrow'/><div class='custom-tooltip tooltip-inner'/></div>)}" data-placement="top" title="{util:serialize-html(for $change in $relevant-changes[@From/string()=$tmp] return <li>{$change}</li>)}">
    {$tmp}
    </span>
    else $tmp
};

(:~
 : Generates table cell with requirements sentence
 : @param $requirement requirement to display
 : @param $inconsistencies differences to previous version
 : @return table cell with requirement sentence (XHTML)
:)
declare function view:requirement-tr($requirement, $inconsistencies) {
  
  <td>
   { (: language the given requirement is stored in is English -> use Englisch template for sentence building :)
     if($requirement/@lng="EN") then ()
        
        (:TODO:)
        
     (: language the given requirement is stored in is German -> use German template for sentence building :)
     else if($requirement/@lng="DE") then 
    
       (: condition :)
       (if($requirement/c:Condition/@Type=("event","logic","timespan")) then
       
          (<span class="re-condition">
          
           {if($requirement/c:Condition/@Type="event") then 
             (<span class="re-condition-conjunction">{$requirement/c:Condition[@Type="event"]/c:Conjunction/string()}</span>,
              <span class="re-condition-subjectDescription">{$requirement/c:Condition[@Type="event"]/c:SubjectDescription/string()}</span>,
              <span class="re-condition-subject">{view:validation-tooltip($inconsistencies, ("CHANGE:ACT_PRED","CHANGE:ACT_PRED_NAME"), $requirement/c:Condition[@Type="event"]/c:Subject/string())}</span>,
              <span class="re-condition-verb">{$requirement/c:Condition[@Type="event"]/c:Verb/string()}</span>)
             
           else if($requirement/c:Condition/@Type="logic") then 
             (<span class="re-condition-conjunction">{$requirement/c:Condition[@Type="logic"]/c:Conjunction/string()}</span>,
              <span class="re-condition-comparisonItem">{view:validation-tooltip($inconsistencies, ("CHANGE:ACT_PRED","CHANGE:ACT_PRED_NAME"), $requirement/c:Condition[@Type="logic"]/c:ComparisonItem/string())}</span>,
              <span class="re-condition-comparisonOperator">{$requirement/c:Condition[@Type="logic"]/c:ComparisonOperator/string()}</span>,
              <span class="re-condition-value">{view:validation-tooltip($inconsistencies, ("CHANGE:ACT_PRED","CHANGE:ACT_PRED_TRANSITION"), $requirement/c:Condition[@Type="logic"]/c:Value/string())}</span>,
              <span class="re-condition-verb">{$requirement/c:Condition[@Type="logic"]/c:Verb/string()}</span>)
             
           else if($requirement/c:Condition/@Type="timespan") then 
             ()
             
           else ()},
           
           </span>,
       
           (: condition subclause switches liability and system :)
           <span class="re-liability" titel="rechtliche Verbindlichkeit">{$requirement/c:Liability/string()}</span>,
           <span class="re-system">{$requirement/c:System/string()}</span>
         )
      
       
       else (: liability and system in regular order :)
        (<span class="re-system">{$requirement/c:System/string()}</span>,
         <span class="re-liability" titel="rechtliche Verbindlichkeit">{$requirement/c:Liability/string()}</span>),
     
      (: main sentence without condition :)
      <span class="re-actor">{view:validation-tooltip($inconsistencies,("CHANGE:ACT_PERF","DIFF_ACT_TASKTYPE"),$requirement/c:Actor/string())}</span>,
      <span class="re-functionality" style="width:13%">{$requirement/c:Functionality/string()}</span>,
      <span class="re-object-detail1">{$requirement/c:ObjectDetail1/string()}</span>,
      <span class="re-object">{view:validation-tooltip($inconsistencies,("CHANGE:ACT_NAME","CHANGE:DS_INPUT_NAME","CHANGE:DS_OUTPUT_NAME","CHANGE:DO_INPUT_NAME","CHANGE:DO_OUTPUT_NAME"),$requirement/c:Object/string())}</span>,
      <span class="re-object-detail2">{$requirement/c:ObjectDetail2/string()}</span>,
      <span class="re-processverb-detail">{$requirement/c:ProcessVerbDetail/string()}</span>,
      <span class="re-processverb">{$requirement/c:ProcessVerb/string()}</span>
      
    )
      
      else ()
      
      
    }
  </td>
};