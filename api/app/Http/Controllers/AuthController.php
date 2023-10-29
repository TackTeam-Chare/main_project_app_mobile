<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
class AuthController extends Controller
{
//     public function deleteUser()
// {
//     $user = auth()->user();
//     $user->delete();

//     auth()->logout(); // ล็อกเอาท์ผู้ใช้หลังจากลบบัญชี

//     return response(['message' => 'User deleted successfully.'], 200);
// }
public function deleteUser(Request $request)
{
    $user = User::find(Auth::user()->id);
    // $category->title = $request->title;
    $user->delete();
    return response(['message' => 'delete Success']);
}
    //Register user
    public function register(Request $request)
    {
        //validate fields
        $attrs = $request->validate([
            'name' => 'required|string',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6|confirmed'
        ]);

        //create user
        $user = User::create([
            'name' => $attrs['name'],
            'email' => $attrs['email'],
            'password' => bcrypt($attrs['password'])
        ]);

        //return user & token in response
        return response([
            'user' => $user,
            'token' => $user->createToken('secret')->plainTextToken
        ], 200);
    }

    // login user
    public function login(Request $request)
    {
        //validate fields
        $attrs = $request->validate([
            'email' => 'required|email',
            'password' => 'required|min:6'
        ]);

        // attempt login
        if(!Auth::attempt($attrs))
        {
            return response([
                'message' => 'Invalid credentials.'
            ], 403);
        }

        //return user & token in response
        return response([
            'user' => auth()->user(),
            'token' => auth()->user()->createToken('secret')->plainTextToken
        ], 200);
    }

    // logout user
    public function logout()
    {
        auth()->user()->tokens()->delete();
        return response([
            'message' => 'Logout success.'
        ], 200);
    }

    // get user details
    public function user()
    {
        return response([
            'user' => auth()->user()
        ], 200);
    }

    // update user
public function update(Request $request)
{
    $user = auth()->user();

    $attrs = $request->validate([
        'name' => 'string',
        'email' => 'email|unique:users,email,' . $user->id,
        'password' => 'string|min:6',
    ]);

    if (isset($attrs['password'])) {
        $attrs['password'] = bcrypt($attrs['password']);
    }

    $user->update($attrs);

    $message = 'Updated successfully.';

    if (!$user->wasChanged()) {
        $message = 'No changes were made.';
    }

    return response([
        'user' => $user,
        'message' => $message,
    ], 200);
}
public function changePassword(Request $request)
{
    $user = auth()->user();

    $attrs = $request->validate([
        'password' => 'string|min:6'
    ]);

    // ตรวจสอบว่ารหัสผ่านใหม่ไม่เหมือนรหัสผ่านเดิม
    if (isset($attrs['password']) && Hash::check($attrs['password'], $user->password)) {
        return response(['message' => 'New password must be different from the old password.'], 400);
    }

    // ถ้ารหัสผ่านใหม่ไม่เหมือนรหัสผ่านเดิมหรือไม่มีการอัปเดตรหัสผ่านเลย
    if (isset($attrs['password'])) {
        $attrs['password'] = bcrypt($attrs['password']);
    }

    $user->update($attrs);

    $message = 'Updated successfully.';

    if (!$user->wasChanged()) {
        $message = 'No changes were made.';
    }

    return response([
        'user' => $user,
        'message' => $message,
    ], 200);
}



public function changeEmail(Request $request)
{
    $user = auth()->user();

    $attrs = $request->validate([
       
        'email' => 'email|unique:users,email,' . $user->id,
      
    ]);

   
    $user->update($attrs);

    $message = 'Updated successfully.';

    if (!$user->wasChanged()) {
        $message = 'No changes were made.';
    }

    return response([
        'user' => $user,
        'message' => $message,
    ], 200);
}


}