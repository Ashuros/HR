package hr.controller;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.VBoxBuilder;
import javafx.scene.text.Text;
import javafx.stage.Modality;
import javafx.stage.Stage;

import javax.swing.*;
import java.io.IOException;
import java.math.BigDecimal;

public class DelimeterWindowController extends ControllerFactory {

    @FXML
    private AnchorPane anchorPaneDelimeterInput;

    @FXML
    private TextField textFieldDelimeter;

    @FXML
    private Button btnAcceptDelimeter;

    @FXML
    private Button btnCancelDelimeter;

    private String delimeter;

    @FXML
    public void handleInputDelimeter(KeyEvent key) {
        if (key.getCode().equals(KeyCode.ENTER)) {
            anchorPaneDelimeterInput.requestFocus();
            delimeter = textFieldDelimeter.getText();
            btnAcceptDelimeter.setDisable(false);
            btnCancelDelimeter.setDisable(false);
        }
    }

    @FXML
    public void handleAction(ActionEvent event) throws IOException, ClassNotFoundException, UnsupportedLookAndFeelException, InstantiationException, IllegalAccessException {
        if (event.getSource() == btnAcceptDelimeter && callerMethod.equalsIgnoreCase("save")) {
            hrService.saveDataToFileByTableName(tableName, delimeter);
        } else if (event.getSource() == btnAcceptDelimeter && callerMethod.equalsIgnoreCase("load")) {
            mainWindowController.setNumberOfRows(hrService.loadDataFromFile(mainWindowController.getFile().getParent(), mainWindowController.getFile().getName(), delimeter));
            UIManager.setLookAndFeel("com.sun.java.swing.plaf.windows.WindowsLookAndFeel");
            if (mainWindowController.getNumberOfRows().compareTo(BigDecimal.valueOf(-1)) == 0) {
                JOptionPane.showMessageDialog(null, "Mr Rodzyn no access to this directory!!");
            } else if (mainWindowController.getNumberOfRows().compareTo(BigDecimal.valueOf(-2)) == 0) {
                JOptionPane.showMessageDialog(null, "Mr Rodzyn, you chose wrong file!!");
            } else {
                JOptionPane.showMessageDialog(null, "Inserted " + mainWindowController.getNumberOfRows() + " rows.");
            }
        }
        goBackToMainWindow(btnCancelDelimeter);
    }
}
