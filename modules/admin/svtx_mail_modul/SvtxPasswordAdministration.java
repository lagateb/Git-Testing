package modules.admin.svtx_mail_modul;


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.censhare.manager.mailmanager.MailService;
import com.censhare.server.kernel.CenShareServer;
import com.censhare.server.kernel.Command;
import com.censhare.server.support.util.MasterDataLogger;
import com.censhare.server.support.util.MasterDataLogger.DatabaseMasterDataLogger;
import com.censhare.server.support.util.MasterDataLogger.Mode;
import com.censhare.support.rmi.RMIUtil;
import com.censhare.support.service.ServiceLocator;
import com.censhare.support.util.DetailException;
import com.censhare.support.xml.AXml;

public final class SvtxPasswordAdministration {

    private Command command;
    private Logger logger;
    private boolean noMailMessage = false;
    private boolean invalidMailMessage = false;
    private DatabaseMasterDataLogger masterDataDBLogger;

    public SvtxPasswordAdministration(Command command) {
        this.command = command;
        masterDataDBLogger = new MasterDataLogger.DatabaseMasterDataLogger(this.getClass().getName(), command.getTransactionManager(), command.getUserID()) ;
        logger = command.getLogger();
    }

    /** Checks, if all selected parties have a valid e-mail address assigned. */
    public int checkEmailAddress() throws Exception {
        AXml cmdXml = (AXml) command.getSlot(Command.XML_COMMAND_SLOT);

        AXml partiesXml = cmdXml.find("selection");
        if(partiesXml == null)
            return Command.CMD_COMPLETED;

        for (AXml partyXml = partiesXml.getFirstChildElement(); partyXml != null; partyXml = partyXml.getNextSiblingElement()) {
            String email = partyXml.getAttr("email", "");
            if (email.length() == 0)
                throw new DetailException(SvtxPasswordAdministration.class, "password-administration-no-email",
                    partyXml.getAttr("display_name"));
            if (!isValidEmailAddress(email))
                throw new DetailException(SvtxPasswordAdministration.class, "password-administration-invalid-email",
                    partyXml.getAttr("display_name"), email);
        }

        return Command.CMD_COMPLETED;
    }

    private boolean isValidEmailAddress(String email) {
        return email.matches(".+@.+\\..+");
    }

    public int sendNewPassword() throws Exception {

    	AXml cmdXml = (AXml) command.getSlot(Command.XML_COMMAND_SLOT);

        AXml partyXml = cmdXml.find("selection");

        if (partyXml == null)
            return Command.CMD_COMPLETED;


        Connection con = command.getTransactionManager().getConnection();
        PreparedStatement stmt;

        partyXml = partyXml.getFirstChildElement();
        // for each selected user
        while (partyXml != null) {
            // create new password
            String password = generatePassword(cmdXml);

            byte[] pwDigest = RMIUtil.getDigest(password);

            int partyId = partyXml.getAttrInt("id", -1);

            // update users password
            String sqlStmt = "UPDATE party SET password = ?, count_invalid_logins = '0', isactive = '1' WHERE isgroup = 0 AND id = ?";
            stmt = con.prepareStatement(sqlStmt);
            stmt.setBytes(1, pwDigest);
            stmt.setInt(2, partyId);

            int resp = stmt.executeUpdate();

            if (resp  > 0){
            	masterDataDBLogger.log(Mode.UPDATED, "party", partyId, "password", "*****", "*****", false);
            }
            stmt.close();

            // inform user by mail
            sendPasswordMail(password, cmdXml, partyXml.getAttr("email",""), partyXml.getAttrInt("id", -1));

            //
            partyXml = partyXml.getNextSiblingElement();
        }

        return Command.CMD_COMPLETED;
    }

    private void showEmptyMessage(AXml cmdXml, int id) {
        AXml messageXml = cmdXml.find("no-mail");
        if(messageXml != null) {
            if(noMailMessage)
                messageXml.setAttr("content", messageXml.getAttr("content") + ", " + id);
            else
                messageXml.setAttr("content", "No Mail-Adress found for user-id: " + id);
        }

        if(noMailMessage)
            return;

        noMailMessage = true;

        cmdXml = cmdXml.find("commands");

        AXml newCommandXml = AXml.createElement("command");
        newCommandXml.setAttr("target", "Client");
        newCommandXml.setAttr("key", "no-mail");
        newCommandXml.setAttr("method", "showMessage");

        cmdXml.appendChild(newCommandXml);
    }

    private void showInvalidMailAdress(int id, AXml cmdXml) {
        AXml messageXml = cmdXml.find("invalid-mail");
        if(messageXml != null) {
            if(invalidMailMessage)
                messageXml.setAttr("content", messageXml.getAttr("content") + ", " + id);
            else
                messageXml.setAttr("content", "Invalid Mail-Adress found for user-id: " + id);
        }

        if(invalidMailMessage)
            return;

        invalidMailMessage = true;

        cmdXml = cmdXml.find("commands");

        AXml newCommandXml = AXml.createElement("command");
        newCommandXml.setAttr("target", "Client");
        newCommandXml.setAttr("key", "invalid-mail");
        newCommandXml.setAttr("method", "showMessage");

        cmdXml.appendChild(newCommandXml);
    }

    private boolean checkValidMailAdress(String mail) {
        return !mail.matches(".*@.*");
    }

    private void sendPasswordMail(String password, AXml cmdXml, String email, int id) {
        if(email.equals("")) {
            showEmptyMessage(cmdXml, id);
            return;
        }

        if(checkValidMailAdress(email)) {
            showInvalidMailAdress(id, cmdXml);
            return;
        }

        MailService mailService = ServiceLocator.getStaticServiceNoEx(MailService.class);
        AXml optionXml = cmdXml.find("options");

        if (mailService == null) {
            logger.warning("Sending email report failed: MailService not found");
            return;
        }

        AXml mailRequestXml = AXml.createElement("mail");
        mailRequestXml.setAttr("account-name", optionXml.getAttr("account", "corpus"));

        AXml mailXml = AXml.createElement("mail");
        mailXml.put("@subject", optionXml.getAttr("subject", "New Password"));
        AXml multipartXml = AXml.createElement("multipart-body");
        AXml contentXml = multipartXml.create("content");
        contentXml.put("@mimetype", "text/html");
        contentXml.put("@transfer-charset", "UTF-8");
        
        
        String content = optionXml.getAttr("content", "Your new password: ");
        if(content != null && content.contains("#password#")) {
        	content = content.replaceAll("#password#", password);
        }
        else {
        	content += password;
        }
        
        contentXml.setTextValue(content);
        mailXml.appendChild(multipartXml);
        mailXml.put("recipient<*>@address", email);

        mailRequestXml.appendChild(mailXml);

        try {
            logger.fine("Trying to send password mail...");
            mailService.sendMail(mailRequestXml);
            logger.fine("Password mail sent!");
        }
        catch (Exception e) {
          logger.log(Level.SEVERE, "Sending email failed: " + e.getMessage(), e);
        }
    }

    private String generatePassword(AXml cmdXml) throws Exception {
        int pwLength = 10;
        if(cmdXml.find("options") != null && cmdXml.find("options").getAttrInt("pw-length") != null)
            pwLength = cmdXml.find("options").getAttrInt("pw-length");

        AXml userAccountingDef = CenShareServer.getInstance().getUserAccountingDefXml();

        ArrayList<Pattern> patterns = new ArrayList<Pattern>();
        for (AXml xml: userAccountingDef.findAll("password-rules.password-rule")) {
            Pattern p = Pattern.compile(xml.getEx("@regex"));
            patterns.add(p);
        }

        char[] alphaNum = "123456789abcdefghjkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ+-.#?=$%".toCharArray();
        StringBuffer sb = new StringBuffer();
        String password = null;
        int maxTries = 100;
        outer: while (--maxTries >= 0) {
            sb.setLength(0);
            for (int i = 0; i < pwLength ; i++) {
                int num = (int)(Math.random() * (alphaNum.length - 1));
                sb.append(alphaNum[num]);
            }
            for (Pattern p: patterns) {
                Matcher m = p.matcher(sb);
                if (!m.matches())
                    continue outer;
            }
            password = sb.toString();
            break;
        }

        if (password == null)
            throw new DetailException(SvtxPasswordAdministration.class, "password-administration-rule-mismatch");

        return password;
    }

    public int resetPassword() throws Exception {
        AXml cmdXml = (AXml) command.getSlot(Command.XML_COMMAND_SLOT);

        AXml partyXml = cmdXml.find("selection");
        List<String> partyList = new LinkedList<String>();

        if(partyXml == null)
            return Command.CMD_COMPLETED;

        partyXml = partyXml.getFirstChildElement();
        while(partyXml != null) {
            partyList.add(partyXml.getAttr("id", "-1"));
            partyXml = partyXml.getNextSiblingElement();
        }

        Connection con = command.getTransactionManager().getConnection();
        // reset password and invalid logins
        StringBuilder sqlStmt = new StringBuilder("UPDATE party SET password = null, count_invalid_logins = '0' WHERE isgroup = 0 AND (id = ?");

        for (int i = 0; i < partyList.size()-1; i++) {
            sqlStmt.append(" OR id = ?");
        }

        sqlStmt.append(")");

        PreparedStatement stmt = con.prepareStatement(sqlStmt.toString());
        for (int i = 0; i < partyList.size(); i++) {
            stmt.setInt(i+1, Integer.parseInt(partyList.get(i)));
        }

       int resp = stmt.executeUpdate();

        if (resp > 0) {
            for (String partyId : partyList) {
                masterDataDBLogger.log(Mode.UPDATED, "party", partyId, "password", "*****", null, false);
            }
        }
        stmt.close();

        return Command.CMD_COMPLETED;
    }

    public int setEmptyHttpPasswords () throws Exception {
        
        logger.warning("Database column >>password_http_digest<< is no longer used, ignoring command step to empty it.");

        /*
        String sqlStmt = "SELECT id, login FROM party WHERE isgroup = 0 AND password IS NULL AND login IS NOT NULL";
        Connection con = command.getTransactionManager().getConnection();
        PreparedStatement stm = null;
        ResultSet rs = null;
        Map<Integer, String> ids = new HashMap<Integer, String>();
        try {
            stm = con.prepareStatement(sqlStmt);
            rs = stm.executeQuery();
            while (rs.next()) {
                ids.put(rs.getInt(1), rs.getString(2));
            }
        }
        finally {
            if (rs != null)
                rs.close();
            if (stm != null)
                stm.close();
        }

        String realm = CenShareServer.getInstance().getRealm();
        int c = 0;
        stm = null;
        try {
            stm = con.prepareStatement("UPDATE party SET password_http_digest = ? WHERE isgroup = 0 AND id = ?");
            for (Map.Entry<Integer, String> e : ids.entrySet()) {
                int id = e.getKey();
                String login = e.getValue();
                byte[] httpDigest = RMIUtil.createHttpDigest(login, realm, "");

                // update users password
                stm.setBytes(1, httpDigest);
                stm.setInt(2, id);

                c += stm.executeUpdate();
                masterDataDBLogger.log(Mode.UPDATED, "party", id, "password_http_digest", "-", "-", false);
            }
        }
        finally {
            if (stm != null)
                stm.close();
        }

        logger.info("Updated " + c + " empty http password digests.");
         */

        return Command.CMD_COMPLETED;
    }
}
