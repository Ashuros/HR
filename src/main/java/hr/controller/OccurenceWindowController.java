package hr.controller;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.AnchorPane;
import javafx.stage.Stage;

import javax.swing.*;
import java.io.IOException;
import java.math.BigDecimal;

public class OccurenceWindowController extends ControllerFactory {

    @FXML
    private AnchorPane anchorPaneOccurenceInput;

    @FXML
    private TextField textFieldCommitOccurence;

    @FXML
    private Button btnAcceptCommitOccurence;

    @FXML
    private Button btnCancelCommitOccurence;

    private int commitOccurence;

    @FXML
    public void handleInputOccurence(KeyEvent key) {
        if (key.getCode().equals(KeyCode.ENTER)) {
            anchorPaneOccurenceInput.requestFocus();
            commitOccurence = Integer.valueOf(textFieldCommitOccurence.getText());
            btnAcceptCommitOccurence.setDisable(false);
            btnCancelCommitOccurence.setDisable(false);
        }
    }

    @FXML
    public void handleAction(ActionEvent event) throws IOException, ClassNotFoundException, UnsupportedLookAndFeelException, InstantiationException, IllegalAccessException {
        if (event.getSource() == btnAcceptCommitOccurence && callerMethod.equals("generate")) {
            mainWindowController.setNumberOfRows(hrService.loadData(tableName + "_BCKP", commitOccurence));
            UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
            if (mainWindowController.getNumberOfRows().compareTo(BigDecimal.valueOf(-1)) == 0) {
                JOptionPane.showMessageDialog(null, "Unknown error.");
            } else if (mainWindowController.getNumberOfRows().compareTo(BigDecimal.valueOf(-2)) == 0) {
                JOptionPane.showMessageDialog(null, "Table doesn't exist.");
            } else {
                JOptionPane.showMessageDialog(null, "Inserted " + mainWindowController.getNumberOfRows() + " rows.");
            }
        }
        goBackToMainWindow(btnCancelCommitOccurence);
    }
}
