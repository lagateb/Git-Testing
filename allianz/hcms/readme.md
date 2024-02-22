# Allianz - HCMS Schnittstelle

Für den externen Zugriff auf censhare-Assets wurde prototypisch eine API basierend auf der Headless-API von censhare aufgesetzt. Im folgenden wird der Ansatz kurz beschrieben.

Es wurde ein Endpoint eingerichtet, der Assets vom Typ Baustein (```article.*```), Text (```text.*```) und Bild (```picture.*```) und dem output-channel ```root.web.``` liefert.


## Aufruf

Momentan sind drei Schemata hinterlegt welche unter folgenden Url aufgerufen werden können
* Baustein - http://localhost:8092/hcms/v1.7/entity/article 
* Text - http://localhost:8092/hcms/v1.7/entity/text
* Bild - http://localhost:8092/hcms/v1.7/entity/image

### Queries

The query language allows specifying conditions using a dot separated path of JSON property names. This specifies the schema type to a filter optionally followed by of one of the comparison operators = , != , < , <= , >= , < , =^ and a JSON encoded value. =^ represents the prefix operator which can only be applied on string values. address.city="New York"
If the comparison operator and the value are missing, the condition tests for the existence of a value (not null). adress.city
The conditions can be combined using boolean logic with the operators in order of precedence ! , & , and | . address.city="New York" & address.street="Broadway"
The precedence can also be modified by grouping the expressions using parenthesis ( , ) . address.city="New York" & (address.street="Broadway" | address.street="Park Avenue")
Conditions sharing the same path prefix can be abbreviated by writing them inside square brackets [ , ] after the common prefix. address[city="New York" & (street="Broadway" | street="Park Avenue")]
In case of arrays/maps of objects, this form must be used in order to evaluate the specified conditions in the context of a single object. For example a query on a company entity with an array of employees: employee.firstName="John" & employee.lastName="Doe"
The query returns all companies having at least one employee with the first name John and also having at least the same or another employee with the last name Doe : employee[firstName="John" & lastName="Doe"]
The query only returns companies having at least one employee with the first name John and the last name Doe .
In case of a reference to another entity, conditions can also be defined on these entities by specifying the entity type in the path using the prefix @ . This syntax must also be used to specify the entity types in a mixed query. related.@person.firstName="John"
It is also possible to search by references in reverse direction, by special syntax using curly braces. Inside these braces, colon separates entity name, field name in that entity that is mapped to reference and condition use to filter that entity. Third part is actually optional can be omitted, together with the last colon. {employee:employed_at:lastName="Doe"} | name="censhare"
{employee:employed_at}_

Quelle: https://ecosphere.censhare.com/de/dokumentation/online-solutions/article/headless-rest


#### Beispiel Abfragen

Liefert alle Bausteine vom Typen Header
```
http://localhost:8092/hcms/v1.7/entity/article?query=type="article.header."
```

Liefert alle Bausteine, welche mit einem einem Text von der Größe S oder M verknüpft sind
```
http://localhost:8092/hcms/v1.7/entity/article?query=text.type="text.size-m." | text.type="text.size-s."
```

Liefert alle Texte, welche den Typen Größe S haben und mit dem Zielgruppen Baustein verknüpft sind. Als logische UND verknüpfung wird %26 gewählt, da & eine semantische Bedeutung innerhalb Url's hat.
```
http://localhost:8092/hcms/v1.7/entity/article?query=type="article.zielgruppenmodul." %26 text.type="text.size-s."
```


