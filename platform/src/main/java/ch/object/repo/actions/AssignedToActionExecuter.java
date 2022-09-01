package ch.object.repo.actions;

import java.util.ArrayList;
import java.util.List;

import org.alfresco.error.AlfrescoRuntimeException;
import org.alfresco.model.ContentModel;
import org.alfresco.repo.action.ParameterDefinitionImpl;
import org.alfresco.repo.action.executer.ActionExecuterAbstractBase;
import org.alfresco.service.cmr.action.Action;
import org.alfresco.service.cmr.action.ParameterDefinition;
import org.alfresco.service.cmr.dictionary.DataTypeDefinition;
import org.alfresco.service.cmr.repository.*;
import org.alfresco.service.cmr.security.AuthorityService;
import org.alfresco.service.namespace.QName;
import org.alfresco.service.namespace.QNamePattern;

/**
 * Action used to add associations from type authority (user or groups) to contents
 *
 * <p>example of use: {code} var action, doc; doc =
 * search.findNode('workspace://SpacesStore/NODE_UUID'); action =
 * actions.create('elesta-action-assignedTo'); action.parameters.property = 'dlc:responsibleAssoc';
 * action.parameters.assignee_name = 'GROUP_'; action.execute(doc); {code}
 *
 * @author Francisco Guariba
 */
public class AssignedToActionExecuter extends ActionExecuterAbstractBase {
  public static final String PARAM_ASSIGNEE_NAME = "assignee_name";
  public static final String PARAM_PROPERTY = "property";
  public static final String PARAM_CONSTRAINT = "assigned-to-constraint-association";
  private static final String GROUP_PREFIX = "GROUP_";

  private NodeService nodeService;
  private AuthorityService authorityService;

  public void setNodeService(NodeService nodeService) {
    this.nodeService = nodeService;
  }

  public void setAuthorityService(AuthorityService authorityService) {
    this.authorityService = authorityService;
  }

  /**
   * (non-Javadoc)
   *
   * @see ActionExecuterAbstractBase#executeImpl(Action, NodeRef)
   */
  @Override
  protected void executeImpl(Action action, NodeRef actionedUponNodeRef) {
    if (!nodeService.exists(actionedUponNodeRef)) {
      throw new AlfrescoRuntimeException("Node does not exist: " + actionedUponNodeRef);
    }

    final var assigneeNameValue = (String) action.getParameterValue(PARAM_ASSIGNEE_NAME);
    final var assignees = assigneeNameValue.trim().split(",");
    final var authorityNames = List.of(assignees);
    final var authorities = new ArrayList<NodeRef>();
    for (String authorityName : authorityNames) {
      if (!authorityName.startsWith(GROUP_PREFIX)) {
        authorityName = GROUP_PREFIX + authorityName;
      }
      final var authority = authorityService.getAuthorityNodeRef(authorityName);
      if (authority != null
          && ContentModel.TYPE_AUTHORITY_CONTAINER.equals(nodeService.getType(authority))) {
        authorities.add(authority);
      }
    }

    /*
     * if any association already exists, use function setAssociations to update it
     * else use the function createAssociation for each association from the list assignee name
     */
    final List<AssociationRef> targetAssocs =
        nodeService.getTargetAssocs(
            actionedUponNodeRef, (QNamePattern) action.getParameterValue(PARAM_PROPERTY));
    if (!targetAssocs.isEmpty()) {
      nodeService.setAssociations(
          actionedUponNodeRef, (QName) action.getParameterValue(PARAM_PROPERTY), authorities);
    } else {
      for (NodeRef authority : authorities) {
        nodeService.createAssociation(
            actionedUponNodeRef, authority, (QName) action.getParameterValue(PARAM_PROPERTY));
      }
    }
  }

  @Override
  protected void addParameterDefinitions(List<ParameterDefinition> paramList) {
    paramList.add(
        new ParameterDefinitionImpl(
            PARAM_PROPERTY,
            DataTypeDefinition.QNAME,
            true,
            getParamDisplayLabel(PARAM_PROPERTY),
            false,
            PARAM_CONSTRAINT));

    paramList.add(
        new ParameterDefinitionImpl(
            PARAM_ASSIGNEE_NAME,
            DataTypeDefinition.TEXT,
            true,
            getParamDisplayLabel(PARAM_ASSIGNEE_NAME)));
  }
}
