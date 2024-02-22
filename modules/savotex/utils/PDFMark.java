package modules.savotex.utils;

import com.censhare.manager.imagemanager.ImageService;
import com.censhare.support.io.FileFactoryService;
import com.censhare.support.io.FileLocator;
import com.censhare.support.service.ServiceLocator;
import com.censhare.support.transaction.CsContext;
import com.censhare.support.util.ExecHelper;
import com.censhare.support.util.logging.ContextLogger;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PDFMark {


    private static final String PARAM_SOURCE_PDF = "srcPDF";
    private static final String PARAM_DEST_PDF = "outPDF";
    private static final String PARAM_PDF_MARKS = "pdfMarksFile";


    private Integer timeout = 600;

    private static final Logger logger = ContextLogger.getLogger(PDFMark.class);

    public PDFMark() {
        logger.log(Level.INFO, "-----> Call PDFMark Init");
    }


    protected String getAbsoluteFileName(String censhareLink) throws IOException {
        FileFactoryService ffs = ServiceLocator.getStaticService(FileFactoryService .class);
        FileLocator fl= ffs.get(censhareLink);
        return fl.getFile().getAbsolutePath();
    }



    private int executeIt(String[] args) throws Exception {
        int exit = -1;

        ExecHelper executer = new ExecHelper();
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        executer.setOutputStreams(outputStream, null);


        // setup execution
        executer.setTimeout(timeout*1000);
        executer.setPollPeriod(2000);

        StringBuffer sb = new StringBuffer();
        for (String arg : args)
            sb.append(arg + " ");
        logger.finer("executing: " + sb);
        exit = executer.execute(args);
        return exit;
    }

    public String getGSPath() {
        ImageService imageService=  ServiceLocator.getStaticService(ImageService.class);
        ImageService.ImageOp imageOp =  imageService.getImageOp();
        return     imageService.getConfiguration().confMap.get("PSRIP").get("@@GS@@");
    }

    /**
     * src
     * dest
     * pdfmark.txt
     *
     */
    public void addMetadata(CsContext ctx, Map<String, Object> xsltArgs) throws Exception {
        logger.log(Level.INFO, "-----> Call addMetadata " );
     // gs -dBATCH -dNOPAUSE  -sDEVICE=pdfwrite -sOutputFile="MASTER.pdf" $(ls input.pdf) pdfmarks

        Args args = new Args(xsltArgs);

        String cmd = getGSPath();
        String outFile = getAbsoluteFileName(args.getStringVal(PARAM_DEST_PDF));
        String pdfFile = getAbsoluteFileName(args.getStringVal(PARAM_SOURCE_PDF));
        String pdfMark = getAbsoluteFileName(args.getStringVal(PARAM_PDF_MARKS));
        executeIt(new String[] {cmd, "-dBATCH","-dNOPAUSE","-sDEVICE=pdfwrite",
                "-sOutputFile="+outFile,pdfFile,pdfMark});
                //tempFile.getFile().getAbsolutePath(),
                //tempDir.getFile().getAbsolutePath()+outFile});
    }

}
