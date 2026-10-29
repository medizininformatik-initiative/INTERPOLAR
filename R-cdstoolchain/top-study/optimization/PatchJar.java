import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

class PatchJar {
  public static void main(String[] args) throws Exception {
    Path classes = Path.of(args[1]);
    // Unlike `jar --update`, ZIP editing leaves embedded module descriptors unchanged.
    try (var archive = FileSystems.newFileSystem(Path.of(args[0]));
        var files = Files.walk(classes)) {
      for (Path source : files.filter(Files::isRegularFile).toList()) {
        Path target = archive.getPath("/" + classes.relativize(source));
        Files.copy(source, target, StandardCopyOption.REPLACE_EXISTING);
      }
    }
  }
}
