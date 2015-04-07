package hr.controller;

import hr.service.HumanResourcesService;
import javafx.fxml.FXMLLoader;
import javafx.geometry.Insets;
import javafx.geometry.Pos;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.layout.VBoxBuilder;
import javafx.scene.text.Text;
import javafx.stage.Modality;
import javafx.stage.Stage;

import java.io.IOException;

public class ControllerFactory {

    protected HumanResourcesService hrService;

    protected FXMLLoader loader;

    protected Parent root;

    protected Stage stage;

    protected String tableName;

    protected String callerMethod;

    protected MainWindowController mainWindowController;

    public void createController(MainWindowController mainWindowController, String caller) {
        this.mainWindowController = mainWindowController;
        this.hrService = mainWindowController.getHrService();
        this.loader = mainWindowController.getLoader();
        this.root = mainWindowController.getRoot();
        this.stage = mainWindowController.getStage();
        this.tableName = mainWindowController.getTableName();
        this.callerMethod = caller;
    }

    public void goBackToMainWindow(Button button) throws IOException {
        stage = (Stage) button.getScene().getWindow();
        stage.setTitle("Main");
        loader = new FXMLLoader(getClass().getResource("/fx/mainWindow.fxml"));
        root = (Parent) loader.load();
        Scene scene = new Scene(root);
        stage.setScene(scene);
        stage.show();
    }
}
