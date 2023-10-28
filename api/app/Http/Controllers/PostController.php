<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Post;
use Illuminate\Support\Str;

class PostController extends Controller
{
    // Get all posts
    public function index()
    {
        return response([
            'posts' => Post::orderBy('created_at', 'desc')
                ->with('user:id,name,image')
                ->withCount('comments', 'likes')
                ->with('likes', function ($like) {
                    return $like->where('user_id', auth()->user()->id)
                        ->select('id', 'user_id', 'post_id')
                        ->get();
                })
                ->get()
        ], 200);
    }

    // Get single post
    public function show($id)
    {
        return response([
            'post' => Post::where('id', $id)->withCount('comments', 'likes')->get()
        ], 200);
    }

    // Create a post
    public function store(Request $request)
    {
        // Validate fields
        $attrs = $request->validate([
            'title' => 'required|string',
            'category' => 'required|string',
            'body' => 'required|string',
            'image' => 'string',
            // 'image' => 'image|mimes:jpeg,png,jpg,gif|max:2048', // Set your validation rules for images
        ]);

        // Handle image upload and save
        $image = null;
        if ($request->hasFile('image')) {
            $image = $this->saveImage($request->file('image'));
        }

        $post = Post::create([
            'title' => $attrs['title'],
            'category' => $attrs['category'],
            'body' => $attrs['body'],
            'user_id' => auth()->user()->id,
            'image' => $attrs['image'],
        ]);

        return response([
            'message' => 'Post created.',
            'post' => $post,
        ], 200);
    }

    // Update a post
    public function update(Request $request, $id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response([
                'message' => 'Post not found.'
            ], 403);
        }

        if ($post->user_id != auth()->user()->id) {
            return response([
                'message' => 'Permission denied.'
            ], 403);
        }

        // Validate fields
        $attrs = $request->validate([
            'title' => 'required|string',
            'category' => 'required|string',
            'body' => 'required|string',
            'image' => 'string',
            // 'image' => 'image|mimes:jpeg,png,jpg,gif|max:2048', // Set your validation rules for images
        ]);

        // Handle image upload and save (if a new image is provided)
        if ($request->hasFile('image')) {
            $image = $this->saveImage($request->file('image'));
            $post->image = $image;
        }

        // Update the post details
        $post->update([
            'title' => $attrs['title'],
            'category' => $attrs['category'],
            'body' => $attrs['body'],
            'image' => $attrs['image'],
        ]);

        return response([
            'message' => 'Post updated.',
            'post' => $post
        ], 200);
    }

    // Delete post
    public function destroy($id)
    {
        $post = Post::find($id);

        if (!$post) {
            return response([
                'message' => 'Post not found.'
            ], 403);
        }

        if ($post->user_id != auth()->user()->id) {
            return response([
                'message' => 'Permission denied.'
            ], 403);
        }

        $post->comments()->delete();
        $post->likes()->delete();
        $post->delete();

        return response([
            'message' => 'Post deleted.'
        ], 200);
    }

    // // Save image and return file path
    // public function saveImage($image,$path = 'public')
    // {
    //     $imageName = Str::random(20) . '.' . $image->getClientOriginalExtension();
    //     $path = 'public/images/posts';
    //     $image->storeAs($path, $imageName);
    //     return asset(Storage::url($path . '/' . $imageName));
    // }
}
