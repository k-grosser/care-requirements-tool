(:~
 : Elicitation assistance view. Combines inconsistency panel, activity context information panel, template editor, and list of requirements for this activity
 : @see masterthesis/modules/care/view/consistency-view (inconsistency panel)
 : @see masterthesis/modules/care/view/stancil-view (template editor)
 : @see masterthesis/modules/care/view/list-view (list of requirements for this activity)
 : @see masterthesis/modules/care/view/info-view (activity context information panel)
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
 : Generates elicitation assistance view, by combination of required panels, to be embedded into the GUI template
 : @param $pkg-id package ID of selected package
 : @param $pkg-version version ID of selected package
 : @param $ref-id activity ID of selected activity
 : @param $req-id requirement ID of (optionally) selected requirement
 : @param $lng active GUI language
 : @return elicitation assistance view (XHTML)
 :)
declare
  %rest:path("requirements-manager/assist/{$pkg-id}/{$pkg-version}/{$ref-id}/{$lng}")
  %restxq:query-param("req-id","{$req-id}")
  %output:method("xhtml")
  %output:omit-xml-declaration("no")
  %output:doctype-public("-//W3C//DTD XHTML 1.0 Transitional//EN")
  %output:doctype-system("http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd")
  function page:start($pkg-id, $pkg-version, $ref-id, $req-id, $lng)
    as element(Q{http://www.w3.org/1999/xhtml}html) {
      
      let $current-package := cm:get($pkg-id,$pkg-version)
      let $compare-package := cm:get($pkg-id,cm:package-before($current-package)/@VersionId/string())
      let $inconsistencies := if($compare-package) then 
                                diff:Activity($compare-package/c:Activity[@Id=$ref-id]/c:ContextInformation,$current-package/c:Activity[@Id=$ref-id]/c:ContextInformation)
                              else ()
      let $care-ref := cm:get($pkg-id, $pkg-version)/c:Activity[@Id=$ref-id]
      let $inconsistencies := consistencymanager:check-consistency($care-ref, $inconsistencies)
      
      return
        ui:page($lng,
        
          <div class="container-fluid">
            <div class="col-md-12">
              {reconsistencyview:consistency-panel($current-package, $compare-package, $ref-id, $req-id, $inconsistencies)}
            </div>
            <div class="col-md-4">
                {reinfoview:info-panel($current-package, $compare-package, $ref-id, $req-id, $inconsistencies)}
            </div>
            <div class="col-md-8">
              {restancilview:stancil-panel($current-package, $compare-package, $ref-id, $req-id, $lng)}       
              {relistview:list-panel($current-package, $compare-package, $ref-id, $req-id, $inconsistencies, $lng)}
            </div>
            
    
            <div class="col-md-12">
              {page:buttons($current-package, $compare-package, $ref-id, $lng)}   
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
 : Generates buttons to navigate foreward and backward through the activities and back to the activity list
 : @param $current-package current package
 : @param $compare-package package to compare the current package with
 : @param $ref-id activity ID of selected activity
 : @param $lng active GUI language
 : @return button panel (XHTML)
 :)
declare function page:buttons($current-package, $compare-package, $ref-id, $lng) {
          let $data-set := cm:filter($current-package, $compare-package, $ref-id)
          let $next-element := util:next-ts($data-set, $data-set[@Id=$ref-id])
          let $prev-element := util:prev-ts($data-set, $data-set[@Id=$ref-id]) 
          return (
            if(util:index-of($data-set, $data-set[@Id=$ref-id]) < count($data-set)) then
              <div class="panel-btn pull-right">
                <a href="{$ui:prefix}/requirements-manager/assist/{$current-package/@Id}/{$current-package/@VersionId}/{$next-element/@Id}/{$lng}" id="nextPage" class="fui-arrow-right pull-right"></a> 
              </div> 
            else (),
            if(util:index-of($data-set, $data-set[@Id=$ref-id]) > 1) then
              <div class="panel-btn">  
                <a href="{$ui:prefix}/requirements-manager/assist/{$current-package/@Id}/{$current-package/@VersionId}/{$prev-element/@Id}/{$lng}" id="prevPage" class="fui-arrow-left"></a> 
              </div> 
            else (),
            <div class="panel-btn back"><a href="{$ui:prefix}/requirements-manager/package/{$current-package/@Id}/{$current-package/@VersionId}/{$lng}" id="prevPage" data-i18n="elicit.backtolist"></a></div>
        )
};

(:~
 : Handle for REST call to delete a requirement from the database. Proxy for REPO delete function
 : @param $pkg-id package ID
 : @param $pkg-version version ID of package requirement to delete belongs to
 : @param $ref-id activity ID of activity requirement to delete belongs to
 : @param $req-id requirement ID of requirement to delete
 : @param $lng active GUI language
 : @return redirect to elicitation assistance view
 :)
declare %restxq:path("relist/delete/{$pkg-id}/{$pkg-version}/{$ref-id}/{$req-id}/{$lng}")
        updating function page:requirements-delete-itemReq($pkg-id, $pkg-version, $ref-id, $req-id, $lng) {
           re:delete-requirement($pkg-id, $pkg-version, $ref-id, $req-id),
           db:output(<restxq:redirect>/requirements-manager/assist/{$pkg-id}/{$pkg-version}/{$ref-id}/{$lng}</restxq:redirect>)
};

(:~
 : Handle for REST call to add a requirement to the database. Proxy for REPO function to add requirements, where all values for all possible variants are passed to.
 : @param $pkg-id package ID of package the requirement belongs to
 : @param $pkg-version-id version ID of package
 : @param $ref-id ID activity ID of activity the requirement belongs to
 : @param $req-id ID requirement ID
 : @param $template-type variant of MASTER template (functional, process, environment, property)
 : @param $condition-type condition type (event, logical, time-span) 
 : @param $condition-comparisonItem comparison object of a condition
 : @param $condition-comparisonOperator relational operator of a condition
 : @param $condition-value camparison value of a condition 
 : @param $condition-event subject of an event-driven condition
 : @param $condition-actor actor of a condition
 : @param $event-object object of a condition
 : @param $event-function function used in a condition
 : @param $event-verb process verb of a condition
 : @param $system system or subject described by the requirement
 : @param $liability legal liability (modal verb) of the requirement
 : @param $actor actor of the requirement
 : @param $functionality type of system activity description
 : @param $object-detail1 detail prefix to the requirement object
 : @param $object object of the requirement
 : @param $object-detail2 detail postfix to the requirement object
 : @param $processverb-detail detail description of the process (complementing the process verb)
 : @param $processverb process verb
 : @param $category requirement category
 : @param $lng active GUI language
 : @return redirect to elicitation assistance view
 :)
declare %restxq:path("restancil/save/{$pkg-id}/{$pkg-version-id}/{$ref-id}/{$lng}")
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
        updating function page:save-requirement($pkg-id, $pkg-version-id, $ref-id, $req-id, $template-type, $condition-type, $condition-comparisonItem, $condition-comparisonOperator, $condition-value, $condition-event, $event-actor, $event-object, $event-function, $event-verb, $logicexpression, $system, $liability, $actor, $functionality, $object-detail1, $object, $object-detail2, $processverb-detail, $processverb, $category, $lng) {
          
          let $condition := switch($condition-type)
                             case "event" return re:new-condition-event($condition-event, $event-actor, $event-object)
                             case "logic" return re:new-condition-logic($condition-comparisonItem, $condition-comparisonOperator, $condition-value, $logicexpression)
                             case "timespan" return re:new-condition-timespan($logicexpression)
                             default return ()
                             
           return
             re:save($pkg-id, $pkg-version-id, $ref-id, $req-id, $template-type, $condition, $system, $liability, $actor, $functionality, $object-detail1, $object, $object-detail2, $processverb-detail, $processverb, $category, $lng),
             db:output(<restxq:redirect>/requirements-manager/assist/{$pkg-id}/{$pkg-version-id}/{$ref-id}/{$lng}</restxq:redirect>)
};