public class CameraManager {
  PVector pos, at, up;
  
  public CameraManager() {
    pos = new PVector(512.0, -68.0, -36.0);
    at = new PVector(280.0, 97.0, 148.0);
    up = new PVector(0.0, 1.0, 0.0);
  }
  
  public void setCamera() {
    camera(pos.x, pos.y, pos.z,        // Camera location
           at.x, at.y, at.z,    // Camera target
           up.x, up.y, up.z);
  }
  
  public void left() { ++pos.x; ++at.x; }
  public void right() { --pos.x; --at.x; }
  public void up() { --pos.y; --at.y; }
  public void down() { ++pos.y; ++at.y; }
  public void forward() { --pos.z; --at.z; }
  public void backward() { ++pos.z; ++at.z; }
  public void tiltUp() { --at.y; }
  public void tiltDown() { ++at.y; }
  
  public void printKeyStates() {
    print("Position: ");print(pos.x);print(" x ");print(pos.y);print(" x ");println(pos.z);
    print(" Look At: ");print(at.x);print(" x ");print(at.y);print(" x ");println(at.z);
    print("  Up Vec: ");print(up.x);print(" x ");print(up.y);print(" x ");println(up.z);
  }
}
