package ch.object.repo.actions;

import java.util.Map;
import java.util.HashMap;

import org.alfresco.repo.action.constraint.BaseParameterConstraint;
import org.alfresco.service.cmr.dictionary.DictionaryService;
import org.alfresco.service.namespace.QName;

public class AssociationParameterConstraint extends BaseParameterConstraint {
  private DictionaryService dictionaryService;

  public void setDictionaryService(DictionaryService dictionaryService) {
    this.dictionaryService = dictionaryService;
  }

  @Override
  protected Map<String, String> getAllowableValuesImpl() {
    final var associations = dictionaryService.getAllAssociations();
    var result = new HashMap<String, String>(associations.size());
    for (QName association : associations) {
      var associationDef = dictionaryService.getAssociation(association);
      if (association != null && associationDef.getTitle(dictionaryService) != null) {
        result.put(association.toPrefixString(), associationDef.getTitle(dictionaryService));
      }
    }
    return result;
  }
}
