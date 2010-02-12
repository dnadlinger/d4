module d4.util.Option;

/**
 * Convenience class for the command line support functionality.
 *
 * We currently cannot nest this into Application due to a compiler bug.
 * TODO: File LDC/DMD bug about this.
 */
class Option {
   this ( char[] newName, char[] newDescription ) {
      name = newName;
      description = newDescription;
   }
   char[] name;
   char[] description;

   int opCmp( Option rhs ) {
      return name < rhs.name ? -1 : name > rhs.name ? 1 : 0;
   }
}
