package modules.msp.allianz.mmc_import.promotion;

import com.censhare.server.kernel.Command;
import com.censhare.support.io.FileFactoryService;
import com.censhare.support.io.FileLocator;
import com.censhare.support.service.ServiceLocator;
import com.censhare.support.util.FileSpec;
import com.censhare.support.xml.AXml;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;


/**
 * Handle hotfolder files:
 * Hotfolder directories defined in command xml
 * Censhare hotfolder handling for in copy to work
 * Get all FileLocator objects for each file in work
 * On completion call complete(fileLocator), on error call error(fileLocator)
 */
public class Hotfolder {

    private final Logger             logger;
    private final FileFactoryService ffs;
    private final FileLocator completedDir;
    private final FileLocator errorDir;
    private final AXml        groupExportNode;

    /**
     * Create instance
     *
     * @param command censhare command
     *
     * @throws Exception on configuration or file system errors
     */
    public Hotfolder(Command command) throws Exception {
        logger = command.getLogger();
        ffs = ServiceLocator.getStaticService(FileFactoryService.class);

        // read parameters
        AXml cmdXml = (AXml) command.getSlot(Command.XML_COMMAND_SLOT);
        AXml inXml = cmdXml.find("import-manager");

        // get specifications of directories
        FileSpec completedDirSpec = FileSpec.createEx(inXml, "@completed-dir-filesystem", "@completed-dir-relpath");
        FileSpec errorDirSpec = FileSpec.createEx(inXml, "@error-dir-filesystem", "@error-dir-relpath");

        // set directories
        completedDir = completedDirSpec.getFileLocator(ffs);
        errorDir = errorDirSpec.getFileLocator(ffs);

        // get the file(s) node
        groupExportNode = cmdXml.find("file-export-group");

        // validate groupExportNode
        if (groupExportNode == null) {
            throw new IllegalArgumentException("unable to find group export node");
        }
    }

    /**
     * Builds the list of file locators.
     *
     * @return list file locators in work
     *
     * @throws IOException on file system errors
     */
    public List<FileLocator> getFileLocators() throws IOException {
        ArrayList<FileLocator> listFileLocators = new ArrayList<>();

        for (AXml fileXml : groupExportNode.findAll("file")) {
            String filesystem = fileXml.getAttr("filesystem", "");
            String url = fileXml.getAttr("url", "");

            listFileLocators.add(ffs.get(filesystem, url));
        }
        return listFileLocators;
    }

    /**
     * move file to completed directory
     *
     * @param fileLocator file locator to move
     *
     * @throws IOException on file system errors
     */
    public void completed(FileLocator fileLocator) throws IOException {
        logger.info("move file to completed folder: " + fileLocator);
        ffs.moveOrCopy(fileLocator, completedDir.concat("file:" + fileLocator.getFileName()), true);
    }

    /**
     * move file to error directory
     *
     * @param fileLocator file locator to move
     *
     * @throws IOException on file system errors
     */
    public void error(FileLocator fileLocator) throws IOException {
        logger.info("move file to error folder: " + fileLocator);
        ffs.moveOrCopy(fileLocator, errorDir.concat("file:" + fileLocator.getFileName()), true);
    }
}
